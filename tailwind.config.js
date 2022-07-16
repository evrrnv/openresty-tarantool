module.exports = {
  content: ["./templates/**/*.html", "./node_modules/flowbite/**/*.js"],
  theme: {
    extend: {},
  },
  plugins: [
    require("tailwindcss"),
    require("autoprefixer"),
    require('flowbite/plugin')
  ],
};
