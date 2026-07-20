import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    // Element Plus 按需引入：模板中用到的 el-* 组件（含 v-loading 指令）自动注册并按需引入样式，
    // 避免全量打包 element-plus（入口 chunk 从 ~976KB 降到 ~34KB）
    Components({
      resolvers: [ElementPlusResolver()],
      dts: false,
    }),
  ],
})
