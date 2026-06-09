import {expect} from 'chai'

describe('vanila', function () {
    it('should always be true', () => {
        expect(true).to.equal(true)
    })

    it('should always be false', () => {
        expect(false).to.equal(false)
    })

    it('should have an empty string', () => {
        expect("").has.length(0)
    })

    it('should detect undefined value', () => {
        let wumpus
        expect(wumpus).to.equal(undefined)
    })
})