const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MissInternetToken");

    const hardhatToken = await Token.deploy();

    // console.log("initial reward",await hardhatToken.rewardsOwing(addr1.address));

    // let tx = await hardhatToken.transfer(addr1.address, ethers.utils.parseEther("100"));
    // await tx.wait();

    // tx = await hardhatToken.transfer(hardhatToken.address, ethers.utils.parseEther("100"));
    // await tx.wait();

    // tx = await hardhatToken.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("95"));
    // await tx.wait();

    // tx = await hardhatToken.connect(addr2).transfer(addr3.address, ethers.utils.parseEther("50"));
    // await tx.wait();

    // console.log("balance before claim", await hardhatToken.balanceOf(addr1.address));

    // console.log("initial reward",await hardhatToken.rewardsOwing(addr1.address));

    // tx = await hardhatToken.connect(addr1).claimRewards();
    // await tx.wait();

    // console.log("balance after claim", await hardhatToken.balanceOf(addr1.address));



    const pancakeFactory = await ethers.getContractFactory("PancakeFactory");
    const hardhatPancakeFactory = await pancakeFactory.deploy(owner.address);
    console.log('owner.address: ', owner.address);
    console.log(await hardhatPancakeFactory.INIT_CODE_PAIR_HASH())

    const WBNB = await ethers.getContractFactory("WBNB");
    const hardhatWBNB = await WBNB.deploy();


    const pancakeRouter = await ethers.getContractFactory("PancakeRouter");
    const hardhatPancakeRouter = await pancakeRouter.deploy(hardhatPancakeFactory.address, hardhatWBNB.address);
    console.log(await hardhatPancakeRouter.addLiquidityETH(owner.address, 1, 0, 0, hardhatToken.address, 99999));


    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  })
})
