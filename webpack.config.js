const { resolve } = require("path");
const TerserWebpackPlugin = require("terser-webpack-plugin");
const OptimizeCssAssetsWebpackPlugin = require("optimize-css-assets-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

/**
 * Enabling `DEV` will enable debug build procedures for the UI
 *
 * WARNING: DO NOT enable this unless you are truly developing
 * the resource. This will dramatically increase bundle sizes.
 */
const DEV = false;

module.exports = {
  mode: DEV ? "development" : "production",
  entry: {
    index: "./html/main.tsx",
  },
  output: {
    path: resolve(__dirname, "dist"),
    filename: "bundle.js",
  },
  resolve: {
    extensions: [".jsx", ".js", ".ts", ".tsx"],
  },
  module: {
    rules: [
      {
        test: /\.[tj]sx?$/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              require("@babel/preset-react"),
              require("@babel/preset-typescript"),
            ],
          },
        },
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.(ttf|otf)$/,
        use: {
          loader: "file-loader",
          options: { outputPath: "fonts" },
        },
      },
    ],
  },
  devtool: DEV ? "eval-source-map" : "source-map",
  optimization: {
    minimize: !DEV,
    minimizer: [
      new TerserWebpackPlugin({}),
      new OptimizeCssAssetsWebpackPlugin({}),
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "bundle.css",
    }),
    new HtmlWebpackPlugin({
      filename: "ui.html",
      template: resolve(__dirname, "html/index.html"),
    }),
  ],
};
