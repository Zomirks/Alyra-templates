import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

async function setUpSmartContract() {
  const mytoken = await ethers.deployContract("ERC20");
  const [owner] = await ethers.getSigners();
  
  return { mytoken, owner };
}

describe("ERC20 contract", function () {
    describe.only("Tests on deploy", function () {
        let mytoken : any;
        let owner : any;

        beforeEach(async () => {
            ({ mytoken, owner } = await setUpSmartContract());
        });
            
        it("Should deploy with rate = 100", async function () {
            expect(await mytoken.rate()).to.equal(0n);
        });
        
        it("Should mint on deploy", async function () {
            
        });

    });

    describe("Tests on buyToken", function () {
        it("Should mint tokens on buyToken", async function () {

        });
    });

    describe("Tests on transfer", function () {
        it("Addresse transfer to shouldn't be mechant", async function () {

        });
    });
});