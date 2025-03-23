# Скрипт визуализации множества молекул-хитов виртуального скрининга.
#
# Формат вызова:
# Rscript plot_hits.R TABLEFILE SETNAME DIAGRAMFILE NCLUSTERS NSELECTED LOGFILE
# TABLEFILE - имя файла с таблицей химического сходства; SETNAME - название
# итогового множества хитов; DIAGRAMFILE - имя выходного файла с диаграммой;
# NCLUSTERS - число кластеров; NSELECTED - число хитов с наилучшими энергиями
# связывания, выбираемых из каждого кластера.
args <- commandArgs(TRUE)
datafile <- args[1]; datasetname <- args[2]; diagramfname <- args[3]
Nclusters <- as.integer(args[4]); TopLigs <- as.integer(args[5])
logfile <- args[6]

png(diagramfname, width = 1200, height = 1000, units = "px", pointsize = 20)

result <- tryCatch(
  {
    similarities.and.energy <- read.table(datafile, row.names = 1, fill = TRUE)
    colnames(similarities.and.energy) <- c("Efficiency", "Energy", rownames(similarities.and.energy))
    similarities <- similarities.and.energy[-c(1,2)]
    energy <- similarities.and.energy[,2]
    distances <- 1-similarities

    if(Nclusters > 1 & length(energy) > 4)
    {
      # Снижение размерности пространства
      ns <- nrow(similarities.and.energy)
      n1 <- floor(ns/3)
      n2 <- floor(ns/2)
      n3 <- 2*n1+1
      fit <- cmdscale(distances,eig=T,k=2)
      
      # Случайный сдвиг точек диаграммы, чтобы они не накладывались друг на друга
      set.seed(20)
      jittereddata <- jitter(fit$points, factor=20)
      kc <- kmeans(jittereddata, centers=Nclusters, algorithm="Hartigan-Wong", nstart=2)
      Nlig <- length(kc$cluster)
      s <- matrix(ncol=6, nrow=Nlig)
      for (i in 1:Nlig) {
        lig <- rownames(similarities.and.energy)[i]; s[i,1] <- lig;
        s[i,2] <- kc$cluster[lig]; s[i,3] <- similarities.and.energy[lig,"Energy"];
        s[i,4] <- similarities.and.energy[lig,"Efficiency"]; s[i,5] <- jittereddata[lig,1]; s[i,6] <- jittereddata[lig,2];
      }
      s <- data.frame(s)
      
      # Создать таблицу с именами молекул, идентификаторами кластеров, значениями
      # энергии связывания и эффективности и сгенерированными 2D-координатами,
      # заполнить ее данными TopLigs лигандов из каждого кластера, лучших по энергии
      smain <- matrix(ncol=6)
      names(smain) <- names(s)
      smain <- data.frame(smain[-1,])
      for (i in 1:Nclusters) { c <- s[s$X2 == i,]; c1 <- head(c[order(c$X3,c$X4,decreasing=TRUE),],TopLigs); smain <- rbind(smain,c1); }
      
      # То же с сортировкой по эффективности
      selected_eff <- matrix(ncol=6)
      names(selected_eff) <- names(s)
      selected_eff <- data.frame(selected_eff[-1,])
      for (i in 1:Nclusters) {
        c <- s[s$X2 == i,]; c1 <- head(c[order(c$X4,c$X3,decreasing=TRUE),],TopLigs); selected_eff <- rbind(selected_eff,c1);
      }
      # Объединить таблицы и отсортировать сначала по идентификаторам кластеров,
      # затем по энергии, затем по эффективности. Записать результат в файл.
      sss <- unique(rbind(smain,selected_eff))
      sss <- sss[order(as.numeric(as.character(sss$X2)), as.numeric(as.character(sss$X3)), as.numeric(as.character(sss$X4))),]
      write.table(sss[1:4], "selected_ligands.txt", quote = FALSE, row.names=FALSE, col.names=FALSE)
      
      # Визуализировать полученную диаграмму.
      plot(jittereddata, xlab="", ylab="", xlim=range(fit$points[,1])+c(-.2,.2), col=kc$cluster, pch=19)
      title(main=sprintf("Хиты виртуального скрининга %s",datasetname))
      
      # Plot the points of selected ligands from the clusters
      points(x=as.numeric(as.character(smain$X5)), y=as.numeric(as.character(smain$X6)), pch=8, cex=2.5, col=as.numeric(as.character(smain$X2)))
      text(x=as.numeric(as.character(smain$X5)), y=as.numeric(as.character(smain$X6)), labels=smain$X1, cex=0.7, pos=sample(c(1:4), replace=T, size=nrow(distances)))
      mtext(paste('Множество', Nlig, 'наилучших хитов разделено на', Nclusters, 'кластеров алгоритмом k-средних.\n Выделены хиты с минимальной энергией связывания.'), side=1, line=3, at=-0.12)
    } else { stop("Too few hits"); }
  }, error = function(e) {
        # Handle the error
        plot.new()
        par(mar = c(0,0,0,0))
        text(x = 0.6, y = 0.5, paste("Ошибка кластеризации и визуализации.\n Возможно, хиты не найдены \n или их количества недостаточно \n для кластеризации и визуализации.\n"), cex = 1.6, col = "black")
        write(e, file = logfile, append = TRUE);
  }, finally = {
        dev.off()
})

