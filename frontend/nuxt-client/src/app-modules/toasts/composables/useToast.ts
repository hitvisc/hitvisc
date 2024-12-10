export const useToast = () => {
  return useNuxtApp().$toast.useToast();
};
