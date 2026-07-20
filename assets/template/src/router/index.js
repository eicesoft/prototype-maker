import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'

// 路由表 = 原型清单。首页卡片和顶部导航都从这里自动读取。
// 新增模块时：
//   1. 在 src/views/ 下新建 <ModuleName>.vue
//   2. 在 routes 里加一条记录（meta.title / meta.desc 必填）
// 无需改动 App.vue 和 Home.vue，它们会自动更新。
const routes = [
  {
    path: '/',
    name: 'home',
    component: Home,
    meta: { title: '原型总览' },
  },
  // 示例：
  // {
  //   path: '/orders',
  //   name: 'orders',
  //   component: () => import('../views/Orders.vue'),
  //   meta: { title: '订单管理', desc: '订单列表、详情与状态流转' },
  // },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.afterEach((to) => {
  document.title = to.meta?.title ? `${to.meta.title} · 原型系统` : '原型系统'
})

export default router
