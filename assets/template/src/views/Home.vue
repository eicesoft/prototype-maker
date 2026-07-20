<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { Monitor, ArrowRight } from '@element-plus/icons-vue'

const router = useRouter()

const modules = computed(() =>
  router.options.routes.filter((r) => r.name !== 'home')
)
</script>

<template>
  <div class="home">
    <div class="hero">
      <h1 class="hero-title">原型总览</h1>
      <p class="hero-sub">共 {{ modules.length }} 个模块，点击进入对应原型页面</p>
    </div>

    <div v-if="modules.length" class="card-grid">
      <router-link
        v-for="m in modules"
        :key="m.name"
        :to="m.path"
        class="module-card"
      >
        <div class="card-icon">
          <el-icon :size="22"><Monitor /></el-icon>
        </div>
        <div class="card-body">
          <div class="card-title">{{ m.meta?.title }}</div>
          <div class="card-desc">{{ m.meta?.desc || '点击查看原型页面' }}</div>
        </div>
        <el-icon class="card-arrow"><ArrowRight /></el-icon>
      </router-link>
    </div>

    <el-empty v-else description="还没有模块，去 src/router/index.js 注册第一个路由吧" />
  </div>
</template>

<style scoped>
.hero {
  margin-bottom: 24px;
}

.hero-title {
  margin: 0 0 8px;
  font-size: 22px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.hero-sub {
  margin: 0;
  font-size: 14px;
  color: var(--color-text-secondary);
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.module-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #ffffff;
  border-radius: 12px;
  box-shadow: var(--shadow-card);
  text-decoration: none;
  transition: box-shadow 0.2s, transform 0.2s;
}

.module-card:hover {
  box-shadow: var(--shadow-card-hover);
  transform: translateY(-2px);
}

.card-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
  flex-shrink: 0;
}

.card-body {
  flex: 1;
  min-width: 0;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.card-desc {
  font-size: 13px;
  color: var(--color-text-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-arrow {
  color: var(--color-text-placeholder);
  flex-shrink: 0;
}

.module-card:hover .card-arrow {
  color: var(--el-color-primary);
}
</style>
