class Player {
    private var kittens: Int
    private var cats: Int
    
    init() {
        kittens = 8
        cats = 0
    }
    
    func insert(kittenOrCat: Int) {
        if kittenOrCat == 1 { // 1 = kitten and 2 = cats
            kittens -= 1
        } else if kittenOrCat == 2 {
            cats -= 1
        }
    }
    
    func booped(kittenOrCat: Int) {
        if kittenOrCat == 1 { // 1 = kitten and 2 = cats
            kittens += 1
        } else if kittenOrCat == 2 {
            cats += 1
        }
    }
    
    func age(numKittens: Int) {
        cats += numKittens
    }
    
    func getKittens() -> Int {
        return kittens
    }
    
    func getCats() -> Int {
        return cats
    }
    
    func setKittens(k: Int) {
        kittens = k
    }
    
    func setCats(c: Int) {
        cats = c
    }
}


