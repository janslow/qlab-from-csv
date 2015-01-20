QLab from CSV
=============

This project is designed to take a list of cues from a spreadsheet (in CSV format) and populate a QLab cue list with them using OSC. *QLab from CSV* is not associated with Figure 53.

Requirements
------------

* `Xcode` for compiling the project.
* [`QLab 3`](http://figure53.com/qlab/) (tested with `3.1.6`).
  * Whilst it is theoretically possible to run qlab-for-ruby over a network, it is recommended to run the QLab instance on the same machine.

Usage
-----

1) Compile the source code using Xcode and run it.
2) In the "Server" drop-down box, select the machine which you want to connect to.
3) In the "Workspace" drop-down box, select the QLab workspace on that machine.
4) Click "Connect"
5) Select any "Cue List" (not yet functional)
6) In QLab, navigate to the cue list you want to append to (clear any previously generated cues).
7) Click "Browse" and locate the CSV input file (see below, "CSV Syntax")
8) Click "Append"

All cues will then be appended to the cue list.

CSV Syntax
----------

The CSV file should be UTF-8 encoded and have the following columns (the order doesn't matter):

* `QLab` - The unique cue number for the cue in QLab. Required.
* `LX` - The cue number to trigger on an Eos desk.
* `Sound`/`Video` - The cue number of the cue to start in QLab (starts cue number prefixed by `S` or `V` respectively).
* `Comment` - Comment to add to the description of the cue.
* `Page` - Page number to add to the description of the cue.

There should be a header row with the column names (as above) at the top of the file.

The `LX`/`Sound`/`Video` accepts instructions which conform to the following rules:

* The value can be empty (this means nothing is done).
* The instruction can be to fire a single cue, identified by a number which can contain letters, numbers, underscores and decimal points (such as `1.32a_v2`).
* Multiple cues can be fired in a single instruction by joining cue numbers with a comma (e.g., `1,2` fires `1` and `2` at the same time).
* Whitespace (spaces, tabs etc.) in lists are ignored (e.g., `1, 2` is identical to `1,2`).
* Cues can be delayed by appending `/dX` (where X is the number of seconds to pre-wait) to a cue number (e.g., `1/d5` fires `1` after 5 seconds).

For example, `1, 2/d3.2` fires `1` immediately then `2` after 3.2 seconds.

As a regular expression:

  ^(\s*[\w\.]+(/d[\d\.]+)?\s*(,\s*[\w\.]+(/d[\d\.]+)?\s*)*)?$

An example of a valid file is `sample_cues.csv` in this repository.