const { environment } = require('@rails/webpacker')

// BootstapのJS(popper.js)を使えるように
const webpack = require('webpack')
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    Popper: 'popper.js'
  })
)

module.exports = environment
