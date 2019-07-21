// scrape material vendor costs
// https://wotlkdb.com/?items&filter=cr=92%3A63%3A151%3A87%3Bcrs=1%3A1%3A1%3A11%3Bcrv=0%3A0%3A0%3A0#0+1-2
text = ""
for (let entry of document.querySelector('.listview-mode-default tbody.clickable').children) {
    // ignore items with a limited stock
    if (entry.children[2].querySelector('span')) {
        continue;
    }
    // ignore items with a non-money currency price
    if (!entry.children[10].querySelector('span')) {
        continue;
    }

    id = entry.children[1].innerText;
    name = entry.children[3].innerText;

    gold = entry.children[10].querySelector('.moneygold');
    gold = (gold !== null ? parseInt(gold.innerText) : 0);
    silver = entry.children[10].querySelector('.moneysilver');
    silver = (silver !== null ? parseInt(silver.innerText) : 0);
    copper = entry.children[10].querySelector('.moneycopper');
    copper = (copper !== null ? parseInt(copper.innerText) : 0);
    cost = 10000 * gold + 100 * silver + copper;

    text += "[\"i:" + id + "\"] = " + cost + ", -- " + name + "\n";
}
console.log(text)

// scrape enchanting scroll info
// https://wotlkdb.com/?items=0.6&filter=cr=86:128:151;crs=11:3:1;crv=0:0:0;ty=6#0+2+1
text = ""
for (let entry of document.querySelector('.listview-mode-default tbody.clickable').children) {
    id = entry.children[0].innerText;
    name = entry.children[2].innerText;

    url = entry.children[7].querySelector('a').href;
    pattern = /\?spell=(\d+)/;
    spellid = pattern.exec(url)[1];

    text += "[" + spellid + "] = \"i:" + id + "\", -- " + name + "\n";
}
console.log(text)