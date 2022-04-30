perl_product_mapper

Installation steps:
1. I hope you have unix-based OS with Perl installed - if not -> pls install Perl somehow
2. You need only some additional Perl modules, which could be installed as a package:
```
sudo apt install libtext-csv-perl
sudo apt install libmoo-perl
sudo apt install libjson-xs-perl
sudo apt install libtest-deep-perl
```


Usage:
```$ perl ./cli.pl  --pricat_file=pricat.csv --mappings_file=mappings.csv --pretty_output --sorted_output```

Stdout:
```
{
   "articles" : {
      "15189-02" : {
         "article_structure" : "Pump",
         "variations" : [
            {
               "article_number_2" : "15189-02 Aviation Nero",
               "article_number_3" : "Aviation",
               "color" : "Nero",
               "ean" : "8719245200978",
               "material" : "Aviation",
               "price_buy_net" : "58.5",
               "price_sell" : "139.95",
               "size" : "European size 38",
               "size_name" : "38"
            },
            {
               "article_number_2" : "15189-02 Aviation Nero",
               "article_number_3" : "Aviation",
               "color" : "Nero",
               "ean" : "8719245200985",
               "material" : "Aviation",
               "price_buy_net" : "58.5",
               "price_sell" : "139.95",
               "size" : "European size 39",
               "size_name" : "39"
            },
...
```

Testing:
```$ prove -v t```

Stdout:
```
t/grouper.t ..
ok 1 - result groupping is ok
1..1
ok
t/mapper.t ...
ok 1 - result mapping is ok
ok 2 - result mapping is ok
ok 3 - result mapping is ok
1..3
ok
All tests successful.
```