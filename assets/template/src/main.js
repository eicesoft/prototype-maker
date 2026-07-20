import { createApp } from 'vue'
// Element Plus 按需引入：模板里的 el-* 组件（含 v-loading 指令）由 unplugin-vue-components
// 自动注册并按需引入样式；以下仅引入 JS API（ElMessage / ElMessageBox / ElNotification）的样式，
// 这类通过函数调用的组件不会被模板扫描覆盖，需手动引入以免样式缺失。
import 'element-plus/es/components/message/style/css'
import 'element-plus/es/components/message-box/style/css'
import 'element-plus/es/components/notification/style/css'
import 'element-plus/es/components/loading/style/css'
import App from './App.vue'
import router from './router'
import './styles/theme.css'

const app = createApp(App)
app.use(router)
app.mount('#app')
