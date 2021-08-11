# Bash Web Crawler

In this project, I will implement a web crawler, indexer and search system using bash.

## Part 1 - The Crawler

The program will crawl Wikipedia using a BFS Algorithm. Starting with the following entry:

[https://en.wikipedia.org/wiki/Cloud_computing](https://en.wikipedia.org/wiki/Cloud_computing)

Limit your program to crawl only the first hundred thousand non-repetitive wiki pages. 

## Part 2 - The Indexer

After crawling these pages and saving them on disk, process the files and extract the words inside each file and save them in form of an indexer in which each file has an alphabetically sorted list of words in which each line has the word and the number of times that word has shown up in that file.

## Part 3 - The Searcher

After creating the indexer files, write down a search script which takes a word as input and outputs the total count of appearance of that word in the files plus the number of times that it appears in each file that has the word.