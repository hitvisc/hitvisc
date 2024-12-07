<template>
  <aside
    class="navbar navbar-vertical navbar-expand-md"
    style="z-index: 0"
  >
    <div class="container-fluid">
      <button
        class="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#sidebar-menu"
        aria-controls="sidebar-menu"
        aria-expanded="false"
        :aria-label="$t('main.menuBtnAriaLabel')"
      >
        <span class="navbar-toggler-icon"></span>
      </button>

      <h1 class="navbar-brand navbar-brand-autodark">
        <router-link to="/">
          <x-icon
            icon="icon-boinc"
            :size="30"
          ></x-icon>
          HiTViSc
        </router-link>
      </h1>

      <div
        id="sidebar-menu"
        class="collapse navbar-collapse"
      >
        <ul class="navbar-nav pt-lg-3">
          <li
            v-for="menuItem in menu"
            :key="menuItem.name"
            class="nav-item"
            :class="{
              active: route.path.startsWith(menuItem.path),
            }"
          >
            <router-link
              v-if="!menuItem.sections"
              class="nav-link"
              :to="menuItem.path"
            >
              <span class="nav-link-icon d-lg-inline-block">
                <x-icon
                  :icon="menuItem.icon"
                  :size="18"
                ></x-icon>
              </span>

              <span class="nav-link-title">
                {{ $t('features.' + menuItem.name) }}
              </span>
            </router-link>

            <template v-else>
              <a
                href="#"
                class="nav-link dropdown-toggle"
                @click="dropdownExpanded[menuItem.name] = !dropdownExpanded[menuItem.name]"
              >
                <span class="nav-link-icon d-lg-inline-block">
                  <x-icon
                    :icon="menuItem.icon"
                    :size="18"
                  ></x-icon>
                </span>
                <span class="nav-link-title">
                  {{ $t('features.' + menuItem.name) }}
                </span>
              </a>
              <div
                class="dropdown-menu"
                :class="{ show: !!dropdownExpanded[menuItem.name] }"
              >
                <router-link
                  v-for="subItem in menuItem.sections"
                  :key="subItem.name"
                  class="dropdown-item"
                  :class="{
                    active: route.path == menuItem.path,
                  }"
                  :to="subItem.path"
                >
                  <span class="nav-link-icon d-lg-inline-block">
                    <x-icon
                      :icon="subItem.icon"
                      :size="18"
                    ></x-icon>
                  </span>
                  <span class="nav-link-title">
                    {{ $t(menuItem.name + '.sections.' + subItem.name) }}
                  </span>
                </router-link>
              </div>
            </template>
          </li>
        </ul>
      </div>

      <div
        v-if="usersStore.currentUser"
        class="nav-item"
      >
        <div class="nav-link d-flex lh-1 text-reset p-0 ps-md-3 py-md-3">
          <span class="avatar avatar-sm bg-primary-lt rounded-circle">
            {{ usersStore.userName[0] }}
          </span>

          <div class="d-none d-md-block ps-2">
            <div>{{ usersStore.userName }}</div>

            <div class="mt-1 small text-muted">{{ usersStore.userEmail }}</div>
          </div>
        </div>
        <div
          v-if="!usersStore.userEmailConfirmed"
          class="nav-link d-flex lh-1 text-reset p-0 ps-md-3"
        >
          <button
            class="btn btn-primary"
            :disabled="isResendingConfirmationLink"
            @click="() => resendConfirmationLink()"
          >
            {{ $t('confirmationEmail.confirmEmail') }}
          </button>
        </div>
      </div>

      <div class="hr my-2"></div>

      <div class="p-3 main__menu-footer">
        <language-switcher class="main__change-lang-btn w-100" />

        <button
          class="btn"
          @click="logout()"
        >
          {{ $t('main.logout') }}
        </button>
      </div>
    </div>
  </aside>
</template>

<script lang="ts" setup>
import { AuthService } from '~/app-modules/auth/services/auth.service';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { UsersClient } from '~/app-modules/users/clients/users.client';

const usersStore = useIOC(UsersStoreProvider).getStore();

const dropdownExpanded = reactive({});

const isResendingConfirmationLink = ref(false);

const menu = [
  {
    name: 'projects',
    path: '/projects',
    icon: 'icon-projects',
  },
  {
    name: 'resources',
    path: '/resources',
    icon: 'icon-resources',
    sections: [
      {
        name: 'public',
        path: '/resources/public',
        icon: 'icon-shield-search',
      },
      {
        name: 'private',
        path: '/resources/private',
        icon: 'icon-shield-check',
      },
      {
        name: 'test',
        path: '/resources/test',
        icon: 'icon-shield-question',
      },
    ],
  },
  {
    name: 'news',
    path: '/news',
    icon: 'icon-news',
  },
  {
    name: 'library',
    path: '/library',
    icon: 'icon-library',
    sections: [
      {
        name: 'targets',
        path: '/library/targets',
        icon: 'icon-target',
      },
      {
        name: 'ligands',
        path: '/library/ligands',
        icon: 'icon-ligand',
      },
    ],
  },
  {
    name: 'notifications',
    path: '/notifications',
    icon: 'icon-notifications',
  },
  {
    name: 'settings',
    path: '/settings',
    icon: 'icon-settings',
  },
];

const route = useRoute();
const usersClient = useIOC(UsersClient);
const authService = useIOC(AuthService);

const { t } = useI18n();

async function resendConfirmationLink() {
  try {
    isResendingConfirmationLink.value = true;
    await usersClient.resendConfirmationLink();
    useToast().success(t('sentConfirmationEmail.text', { email: usersStore.userEmail }));
  } catch (e) {
    useToast().error('Ошибка');
  } finally {
    isResendingConfirmationLink.value = false;
  }
}

function logout() {
  authService.logout();
  if (typeof route.meta.requiresAuth === 'undefined' || route.meta.requiresAuth) {
    useRouter().push('/');
  } else {
    window.location.reload();
  }
}
</script>

<style lang="scss" scoped>
.navbar-brand a {
  align-items: center;
  color: var(--tblr-primary-darken);
  display: flex;
  flex-wrap: nowrap;
  font-weight: 600;

  & .x-icon {
    fill: var(--tblr-primary-darken);
    padding-right: 12px;
  }
}

.router-link-active {
  & .nav-link-title {
    color: var(--tblr-primary-darken);
  }

  & .x-icon {
    color: var(--tblr-primary-darken);
  }
}

.main {
  &__change-lang-btn {
    max-width: 30px;
    text-transform: uppercase;
  }

  &__menu-footer {
    align-items: center;
    display: grid;
    gap: 12px;
    grid-auto-flow: column;
    justify-content: space-between;
  }
}
</style>
