import { defineConfig } from 'unocss'
import extractorPug from '@unocss/extractor-pug'

export default defineConfig({
  extractors: [
    extractorPug(),
  ],
})
