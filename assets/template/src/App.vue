<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

const modules = computed(() =>
  router.options.routes.filter((r) => r.name !== 'home')
)
</script>

<template>
  <div class="app-shell">
    <header class="topbar">
      <router-link to="/" class="brand">原型系统</router-link>
      <nav class="nav">
        <router-link
          v-for="m in modules"
          :key="m.name"
          :to="m.path"
          class="nav-item"
          :class="{ active: route.name === m.name }"
        >
          {{ m.meta?.title }}
        </router-link>
      </nav>
    </header>
    <main class="content">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
}

.topbar {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  gap: 32px;
  height: 56px;
  padding: 0 24px;
  background: #ffffff;
  border-bottom: 1px solid var(--color-border);
}

.brand {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-color-primary);
  text-decoration: none;
  white-space: nowrap;
}

.nav {
  display: flex;
  align-items: center;
  gap: 4px;
  height: 100%;
  overflow-x: auto;
  /* overflow-x 设为非 visible 时，浏览器会把 overflow-y 也算成 auto；
     nav-item 的 border-bottom 会让内容溢出 1px，从而在顶部导航冒出多余垂直滚动条。
     这里强制隐藏 overflow-y，避免该问题。 */
  overflow-y: hidden;
}

.nav-item {
  display: flex;
  align-items: center;
  height: 100%;
  padding: 0 14px;
  font-size: 14px;
  color: var(--color-text-regular);
  text-decoration: none;
  white-space: nowrap;
  border-bottom: 2px solid transparent;
  transition: color 0.2s;
}

.nav-item:hover {
  color: var(--el-color-primary);
}

.nav-item.active {
  color: var(--el-color-primary);
  font-weight: 500;
  border-bottom-color: var(--el-color-primary);
}

.content {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}
</style>
