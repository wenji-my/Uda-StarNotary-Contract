const StarNotary = artifacts.require('StarNotary')

contract('StarNotary', accounts => { 

    let defaultAccount = accounts[0]
    let account1 = accounts[1]
    let account2 = accounts[2]

    const name = 'Star power 103!'
    const story = 'I love my wonderful star'
    const ra = 'ra_032.155'
    const dec = 'dec_121.874'
    const mag = 'mag_245.978'
    let tokenId = 1

    beforeEach(async function() { 
        this.contract = await StarNotary.new({from: defaultAccount})
    })

    describe('can create a star', () => { 
        it('can create a star and get its name', async function () { 
             // Add your logic here
             await this.contract.createStar(name, story, ra, dec, mag, tokenId, {from: account1});
             let info = await this.contract.tokenIdToStarInfo(tokenId)
             assert.equal(info[0], name);
        })
    })

    describe('star uniqueness', () => { 
        it('star already exists', async function () {
            await this.contract.createStar(name, story, ra, dec, mag, tokenId, {from: account1})

            assert.equal(await this.contract.checkIfStarExist(ra, dec, mag), true)
        })
    })

    describe('buying and selling stars', () => { 

        let starPrice = web3.toWei(.01, "ether")

        beforeEach(async function () { 
            await this.contract.createStar(name, story, ra, dec, mag, tokenId, {from: account1})
        })

        it('user1 can put up their star for sale', async function () { 
            // Add your logic here
            await this.contract.putStarUpForSale(tokenId, starPrice, {from: account1})
            assert.equal(await this.contract.starsForSale(tokenId), starPrice)
        })

        describe('user2 can buy a star that was put up for sale', () => { 
            beforeEach(async function () { 
                await this.contract.putStarUpForSale(tokenId, starPrice, {from: account1})
            })

            it('user2 is the owner of the star after they buy it', async function() { 
                // Add your logic here
                await this.contract.buyStar(tokenId, {from: account2, value: starPrice, gasPrice: 0})
                const owner = await this.contract.ownerOf(tokenId, {from: account2})
                assert.equal(owner, account2)
            })

            it('user2 ether balance changed correctly', async function () { 
                // Add your logic here
                let overpaidAmount = web3.toWei(.05, "ether")
                const balanceBeforeTransaction = web3.eth.getBalance(account2)
                await this.contract.buyStar(tokenId, {from: account2, value: overpaidAmount, gasPrice:0})
                const balanceAfterTransaction = web3.eth.getBalance(account2)

                assert.equal(balanceBeforeTransaction.sub(balanceAfterTransaction), starPrice)
            })
        })
    })
})