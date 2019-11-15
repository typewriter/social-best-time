# Social best time: ソーシャルみごろ

- Twitterのツイートを解析し，紅葉・桜の見頃情報を出力する予定．

## Requirements: 動作環境

- Ruby 2.x
- MeCab (mecab-ipadic, [mecab-ipadic-neologd](https://github.com/neologd/mecab-ipadic-neologd))

## Collector: ツイート収集

### Usage

```bash
$ cd collector
$ bundle install
$ ./run.example.sh
$ cat tweet.csv
2019-11-15 01:29:35 UTC,no_clock,都内、イチョウが色づき始めている。紅葉もうすぐ。
```

## Analyzer: ツイート解析

- 実装予定

