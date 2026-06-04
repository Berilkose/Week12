module.exports = {
  plugins: [
    ["@semantic-release/exec", {
      prepareCmd: "python bump_version.py ${nextRelease.version}"
    }],
    "@semantic-release/changelog",
    ["@semantic-release/git", {
      assets: ["CHANGELOG.md", "VERSION"]
    }]
  ]
};
