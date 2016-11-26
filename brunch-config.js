exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["app/assets/css/app.css"]
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    assets: /^(app\/assets\/files)/
  },

  paths: {
    watched: [
      "app/assets",
    ],
    public: "public/static"
  },

  modules: {
    autoRequire: {
      "js/app.js": ["assets/js/app"]
    }
  },

  plugins: {
    babel: {
      ignore: [/app\/assets\/vendor/]
    },
    postcss: {
        processors: [require("postcss-cssnext")]
    }
  },

  npm: {
    enabled: true,
    styles: {
        "normalize.css": ["normalize.css"],
        "tachyons": ["css/tachyons.css"]
    }
  }
};
