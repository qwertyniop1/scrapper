# Scrapper

Essential configurable multithread scrapper for [Petsonic](https://www.petsonic.com/)

### Requirements
* Ruby 2.4.0

### Install
```
git clone https://github.com/qwertyniop1/scrapper.git
cd scrapper
bundle install
```

### Usage
Utility takes 2 required parameters: URL of category index page and output file name.
```
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv
```

You also can configure scrapping with optional arguments. For example, to set logging level (debug, info, warn, error, silent):
```
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv -l debug
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv --log-level debug
```

Number of threads (0 for single thread mode):
```
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv --threads 8
```

Set timeout for response (in seconds):
```
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv --timeout 30
```

Number of tries to get response after failure:
```
ruby lib/scrapper.rb https://www.petsonic.com/condroprotectores-para-gatos/ output.csv --tries 5
```

### Contacts

Семенюк Виталий
- svitas1997@gmail.com
- Linkedin: https://www.linkedin.com/in/vitali-semenyuk/
- Github: https://github.com/qwertyniop1
