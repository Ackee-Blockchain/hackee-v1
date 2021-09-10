const HakceeToken = artifacts.require("HakceeToken");

module.exports = function (deployer) {
  deployer.deploy(HakceeToken);
};
