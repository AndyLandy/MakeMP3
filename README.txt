MakeMP3 is Copyright 2015 by Andrew Paul Landells. 

Introduction
============

MakeMP3 is a cross-platform Perl script for batch-processing lossless CD rips
with cue sheets into MP3 files. It uses ffmpeg and lame, and optionally aacgain
to build an MP3 library with correct metadata.

MakeMP3 takes a cue sheet or cue sheets on the command line and parses them to
create ffmpeg and lame command lines to produce MP3s. It works with full-disc
images or track-by-track rips. The rips can either be raw WAV files, or any
other lossless codec (as long as it's supported by ffmpeg) so should work with
FLAC, WavPack etc.

The metadata of the output MP3 files is *always* based on the cue sheet, any
metadata in the source lossless files is ignored. Please see the section on
metadata further down for more details as to what metadata MakeMP3 supports.

Usage
=====

    MakeMP3 [--ag] [--debug] [--dry-run] source_file ...

Basic usage is very simple. You simply list your cue sheets on the command line
and MakeMP3 will process them all and create the MP3 library in a new directory
called 'makemp3' in the current directory. MP3s are encoded by default with the
lame encoder options '--preset extreme -k'

The command line options work as follows:
    --ag        Apply album gain using aacgain. This estimates the average
                perceived loudness of the entire album and applies a lossless
                gain change to adjust it to a reference level of 89dB sound
                pressure level.
    
                For more specifics about adjusting gain, how it works, and why
                you might want to do this, you should look into 'mp3gain'

    --debug     Prints out lots of debugging information. Mostly useful for
                development purposes, but can also be helpful to work out why
                your cue sheets aren't generating the output files you expect.
    
    --dry-run   Performs a dry-run. Useful for checking your cue sheets are
                well-formed and can be parsed by MakeMP3. Combining --debug and
                --dry-run is a good way to test what MakeMP3 will do before you
                commit to running a large encoding job.

Cue Sheets and Metadata
=======================

The cue sheet file format originated in CDRWIN as a way of representing the
metadata structure of an audio CD or CD-ROM independent from the data itself.
The format encapsulates the important information from an audio CD's table of
contents (TOC) as well as supporting some additional fields used for CD-Text.

Many current CD ripping tools support generation of cue sheets alongside the
extracted audio data. The most prominent example is Exact Audio Copy (EAC) for
Windows. Under OSX, X Lossless Decoder (XLD) is a good choice. Under Linux,
cue sheets can be generated using cdrdao and cuetools, most likely paired with
cdparanoia to extract the actual audio data.

A cue sheet will usually look something along these lines:

TITLE "My First Album"
PERFORMER "The Musical Artists"
REM DATE 2000
REM GENRE Pop
FILE "CDImage.wv" WAVE
    TRACK 01 AUDIO
        TITLE "The first track"
        INDEX 01 00:00:00
    TRACK 02 AUDIO
        TITLE "The second track"
        INDEX 01 05:23:47

MakeMP3 uses many of these cue sheet fields to provide metadata for the output
MP3 files. As the cue sheet format is relatively limited, some standard comment
types are also used by MakeMP3. A list of supported cue sheet fields is listed
below. Note that some fields can appear either at the top level, at the track
level, or both. Usually, MakeMP3 will search for metadata at the track-level,
if it fails to find any, it will default to the top-level entry.

TITLE
    This is used to specify the track title. MakeMP3 will also explicitly use
    the top-level TITLE field for the album title.

PERFORMER
    This is used to specify the artist field. MakeMP3 will also explicitly use
    the top-level PERFORMER field for the album artist (TPE2) field.

SONGWRITER
    This is used to set the composer field.

REM ARTWORK
    Specifies the path to an image to be used as the embedded album artwork

REM COMMENT
    Sets the comment field.

REM DATE
    Sets the year field.

REM GENRE
    Sets the genre field.

REM DISCNUMBER
    Sets the disc number (part of set) number. Defaults to '1' if unspecified.

REM TOTALDISCS
    Sets the total number of discs in a set. Defaults to the same value as
    DISCNUMBER if unspecified.

REM COMPILATION TRUE
    Sets the "Part of a compilation" flag.

TRACK nn AUDIO
    The TRACK directive is a mandatory field in a cue sheet. MakeMP3 also uses
    it to set the track number. The total number of tracks is set to the
    highest track number that's declared in the cue sheet.

Bugs, Known Issues and Planned Features
=======================================

MakeMP3 was originally written to fulfil a specific need, so it's currently
fairly limited in many regards and isn't tremendously configurable.

 *  lame and aacgain settings are hard-coded into MakeMP3. These should be
    user-customisable, ideally in a separate configuration file.

 *  The encoder should be decoupled from MakeMP3 so something other than lame
    can be used instead. Ideally, this will use an abstract templating scheme
    much like EAC does, so any encoder can be used.

 *  Track gain support needs to be added.

EAC's own brand of 'non-compliant' cue sheets isn't supported. MakeMP3's
internal representation of cue sheets makes this non-trivial to implement. If
you really care that much about your pregaps, consider ripping your CDs as
full-disc rips.

Licensing
=========

MakeMP3 is Copyright 2015 Andrew Paul Landells

MakeMP3 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled "GNU
Free Documentation License".
