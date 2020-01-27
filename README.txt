MakeMP3 is Copyright 2015-2020 by Andrew Paul Landells. 

Introduction
============

MakeMP3 is a cross-platform Perl script for batch-processing lossless CD rips
with cue sheets into MP3 files. It uses ffmpeg and lame, and optionally
aacgain, to build an MP3 library with correct metadata.

MakeMP3 takes one or more cue sheets on the command line and parses them to
create ffmpeg and lame command lines to produce MP3s. It works with full-disc
images or track-by-track rips. The audio can be either WAV or any other
lossless codec supported by ffmpeg including FLAC and WavPack.

The metadata of the output MP3 files is *always* based on the cue sheet; any
metadata in the audio files is ignored. Please see the section on metadata
further down for more details as to what metadata MakeMP3 supports.

Usage
=====

    MakeMP3 [--conf=file] [--ag] [--tg] [--debug] [--dry-run] source_file ...

Basic usage is very simple: list your cue sheet(s) on the command line and
MakeMP3 will process them all and place the resulting MP3 library in a new
directory called 'makemp3', created in the working directory. MP3s are encoded
by default with the lame encoder options '--preset extreme -k'

The command-line options work as follows:
    --conf      Use specificed configuration file instead of MakeMP3 defaults
                Please see the 'Configuration' section below for more details

    --ag        Apply album gain using aacgain. This estimates the average
                perceived loudness of the entire album and applies a lossless
                gain change to approximately match it to a reference of 89dB
                sound pressure level.

                For more specifics about adjusting gain, how it works, and why
                you might want to do this, you should look into 'mp3gain'.

    --tg        Apply track gain using aacgain. This estimates the average
                perceived loudness of each track individually and applies a
                lossless gain chainge to approximately match it to a reference
                of 89dB sound pressure level.

    --force     By default, MakeMP3 will not overwrite existing files unless the
                timestamp on the source cue sheet is newer than that of the
                output file. Using the force option means MakeMP3 will *always*
                attempt to create a new file, overwriting files if necessary.

    --debug     Prints out lots of debugging information, which is mostly useful
                for development purposes, but can also be helpful to work out
                why your cue sheets aren't generating the output you expect.

    --dry-run   Performs a dry run for checking that your cue sheets are
                well-formed and can be parsed by MakeMP3. Combining --debug and
                --dry-run is a good way to test what MakeMP3 will do before you
                commit to running a large encoding job.

Prerequisites
=============

MakeMP3 is not a standalone product, rather a wrapper around existing tools.
It relies on the presence of other software to achieve its goals. To make full
use of MakeMP3, you will need the following tools available on your system.

 *  Perl
    MakeMP3 is an interpreted Perl script, so you will need a Perl interpreter
    installed to use it. Perl is standard on macOS and most Linux distributions.

    Additionally, you will need the Perl 'JSON' module. This may be available
    via package management on some Linux distributions, or can be obtained via
    CPAN

    By its nature, MakeMP3 is designed to run best in a UNIX command-line
    environment and is straightforward to set up in Linux or on macOS. If you
    wish to use it on a Windows system, you will get best results if you use
    Cygwin to provide a UNIX-like environment for it to operate in.

 *  ffmpeg
    ffmpeg does the majority of the back-end processing of MakeMP3. It is used
    to read the source files indicated by the cue sheets, excerpt the individual
    tracks, and apply the pre-emphasis filter if necessary. You should ensure
    that your version of ffmpeg is compiled to support all the features you will
    require. In particular, it's not uncommon to find ffmpeg builds that do not
    support the pre-emphasis filter.

 *  LAME (or another encoder)
    By default, MakeMP3 uses LAME to create MP3 files. Whilst ffmpeg supports
    encoding audio using LAME libraries, the standalone LAME software supports
    more configuration options and richer metadata.
    
    MakeMP3's customisable configuration allows you to switch out lame for
    another encoder should you so wish. This could simply be ffmpeg, or a tool
    for creating other formats: e.g. AAC, Ogg Vorbis, or Opus.

 *  aacgain (or an alternative) (optional)
    MakeMP3 has options for gain-levelling its output files. The default
    configuration uses aacgain for this, however the configuration system allows
    you to choose a different tool if a suitable one exists.

Custom Configuration
====================

MakeMP3 supports custom configurations by way of the --conf switch. This allows
you to customise much of MakeMP3's behaviour. In particular, you can use 
alternative encoding engines and control metadata creation. Some sample
configuration files are provided as a starting point.

A MakeMP3 configuration file is a JSON-formatted text file that specifies the
following configuration options. Defaults will be used if an option is not
explicitly specified.

{
    "VERSION"  : The version of the MakeMP3 configuration file format. This
                 exists to allow MakeMP3 to support different configuration
                 file formats in future, should any shortcomings in the current
                 format come to light. For this version of MakeMP3, this value
                 must be set to "1"
    "DESTDIR"  : The name of a destination directory for MakeMP3 to put its
                 output files. This can be relative to the current path, or can
                 be an absolute path.
    "FFMPEG"   : Specifies the path to your ffmpeg binary. If set simply to 
                 "ffmpeg" then the version on your path will be used.
    "FFQUIET"  : Command-line option to run ffmpeg in quiet mode. This flag is
                 enabled in standard operation, but not if --debug is set.
    "FFOPTS"   : Command-line options required for ffmpeg to extract audio from
                 a source file. Do not change this unless you know what you are
                 doing!
    "FILTER"   : Command-line options required to use ffmpeg's pre-emphasis
                 filter. Again, this should be left as-is unless you understand
                 the implications of changing it.
    "AACGAIN"  : Specifies the path to your aacgain binary. If set simply to
                 "aacgain" then the version on your path will be used.
    "AGQUIET"  : Command-line option to run aacgain in quiet mode. This flag is
                 enabled in standard operation, but not if --debug is set.
    "AAGOPTS"  : Command-line options to run aacgain in album-gain mode.
    "ATGOPTS"  : Command-line options to run aacgain in track-gain mode.
    "ENCODER"  : Path to "lame" or another encoder. Behaves the same as ffmpeg
                 and aacgain options.
    "ENQUIET"  : Command-line option to silence your encoder unless --debug is
                 specified
    "ENCOPTS"  : Command-line options to specify your encoder settings.
    "FILEEXT"  : The file extension for your output files. Most likely ".mp3"
    "METADATA" : [],
}

A word on metadata:

METADATA is a JSON array of additional strings to append to your encoder. These
will predominantly be for metadata, and MakeMP3 provides a rich set of templates
for extracting data from the cue sheets. You may also need a command-line switch
to specify your output file. That switch should be the last entry in the array
as MakeMP3 will append the output filename after everything else.

You can reference any directive in the cue sheet by prefixing it with a percent
symbol, for example the artist name can be referenced as %PERFORMER. MakeMP3
will return specific track values of field, unless they are not set, in which
case it will use the value set at the root-level of the cue sheet. If you wish
to explicitly refer to a value set in the root of the cue sheet, use two percent
symbols, so %%TITLE will return the album title. Finally, you can 'test' a value
using %?, so %?COMPILATION will return 1 if the COMPILATION flag is set to TRUE,
and 0 if it's set to FALSE.

Finally, there are some internal values that you can use in your metadata, they
are as follows:
%_CUEPATH     - The absolute path to the cue sheet. Useful for turning relative
                paths within the cue sheet to absolute ones. Necessary if you
                want to embed album artwork in your files.
%_ENCODER     - The value of the ENCODER configuration option, minus path.
%_ENCOPTS     - The value of the ENCOPTS configuration option.
%_FLAGS_flag  - The cue sheet FLAGS directive specifies a space-separated list
                of flags. If you wish to reference any of these, they will be
                of the form %_FLAGS_name-of-flag. You can also use %? notation
                to test these values, so '%?_FLAGS_PRE' will return '1' if the
                pre-emphasis flag is set.
%_TOTALTRACKS - The largest track number that MakeMP3 found in the cue sheet
                (This should normally be the last track, but may not be.)
%_VERSION     - The version string of MakeMP3 you're using.

Cue Sheets and Metadata
=======================

The cue-sheet file format originated in CDRWIN as a way of representing the
structure of an audio CD or CD-ROM independently of the data itself. The format
encapsulates both the important track information from an audio CD's table of
contents (TOC) and certain subcode-embedded metadata such as index marks and
CD-Text.

Many current CD-ripping tools support generation of cue sheets alongside the
extracted audio data; the most prominent example is Exact Audio Copy (EAC) for
Windows. Under OSX, X Lossless Decoder (XLD) is a good choice. Under Linux,
cue sheets can be generated using cdrdao and cuetools, most likely paired with
cdparanoia to extract the actual audio data.

A cue sheet will usually look something like this:

TITLE "My First Album"
PERFORMER "The Musical Artists"
REM DATE 2000
REM GENRE "Pop"
FILE "CDImage.wv" WAVE
  TRACK 01 AUDIO
    TITLE "The first track"
    INDEX 00 00:00:00
    INDEX 01 00:00:30
  TRACK 02 AUDIO
    TITLE "The second track"
    INDEX 00 05:23:42
    INDEX 01 05:23:47

If you use EAC to rip track-by-track with pregaps, you will generate what's
known as an EAC "non-compliant" cue sheet. As of MakeMP3 1.2.1, this is now a
supported cue sheet format. Such a cue sheet will look something like this:

TITLE "My First Album"
PERFORMER "The Musical Artists"
REM DATE 2000
REM GENRE "Pop"
FILE "Track 01.wv" WAVE
  TRACK 01 AUDIO
    TITLE "The first track"
    INDEX 00 00:00:00
    INDEX 01 00:00:30
  TRACK 02 AUDIO
    TITLE "The second track"
    INDEX 00 05:23:42
FILE "Track 02.wv" WAVE
    INDEX 01 00:00:00

MakeMP3 uses many of these cue-sheet directives to provide metadata for the
output MP3 files. As the cue-sheet format is relatively limited, some standard
comment types are also used by MakeMP3; supported cue-sheet fields are listed
below. Note that some fields can appear at either the top level, the track
level, or both. For most metadata fields, MakeMP3 will search at the track
level, and, if not found, will fall back to the corresponding top-level entry
(if present).

TITLE
    Specifies the "song name" field if defined at the track level
    Specifies the "album" field if defined at the top level
    If a track-level definition isn't found, MakeMP3 will use the top-level
    definition (if any) for both "song name" and "album"

PERFORMER
    Specifies the "artist" field if defined at the track level
    Specifies the "album artist" field if defined at the top level
    If a track-level definition isn't found, MakeMP3 will use the top-level
    definition (if any) for both "artist" and "album artist"

SONGWRITER
    Specifies the "composer" field

REM ARTWORK
    Relative path to an image to be inserted as the embedded album artwork

REM COMMENT
    Specifies the "comment" field

REM DATE
    Specifies the "year" field

REM GENRE
    Specifies the "genre" field

REM DISCNUMBER
    Sets the disc number of a set; defaults to '1' if unspecified

REM TOTALDISCS
    Sets the total number of discs in the set; defaults to the same value as
    DISCNUMBER if unspecified

REM COMPILATION TRUE
    Sets the "Part of a compilation" flag. Strictly speaking, this should be
    considered to be a "various artists" flag, rather than the strict
    definition of a "compilation" album. You don't want to set it if there is
    a defined album artist.

REM SKIP TRUE
    Causes MakeMP3 to completely skip a track. Useful if you only want to
    encode a subset of the tracks. Particularly useful for albums with hidden
    tracks at the end, preceded by lots of silence. If this directive is put
    at the top level of the cue sheet, the entire album is skipped. If you set
    this flag at the top level, it can be overridden on a track-by-track basis
    with the inverse, REM SKIP FALSE

TRACK nn AUDIO
    The TRACK directive is mandatory for each track of a cue sheet; MakeMP3
    also uses it to set the track-number tag. The total number of tracks is set
    to the highest track number declared in the cue sheet.

INDEX nn mm:ss:ff
    INDEX directives are used to declare timestamps in the cue sheet. They are
    of the form mm:ss:ff -- minutes, seconds and frames. A frame is defined as
    1/75th of a second. The cue sheet format (but not MakeMP3 itself) mandates
    that every track have an INDEX 01 directive for its start; others are
    optional, including INDEX 00, which represents the start of the track's
    pregap, if any. Indexes 02 onward are typically used for marking
    subsections (e.g. movements). Although the cue-sheet format does not
    explicitly support fractional and out-of-range values in timestamp fields,
    MakeMP3 will process these correctly, making e.g. 99.5:66:108.3 correspond
    to 100:37:33.3.

    MakeMP3 currently only uses INDEX 01 values. A track is encoded from its
    INDEX 01 to the INDEX 01 of the following track (if present). If MakeMP3
    cannot find a track's start or end time in the cue sheet, the current audio
    file's start or end is used instead.

REM END mm:ss:ff
    REM END directives are timestamps, formatted the same as INDEX markers.
    If you specify an END timestamp in a track declaration, that timestamp is
    used to end the track, instead of the INDEX 01 of the subsequent track.

Running MakeMP3 in batch mode with multiple threads
===================================================

Most modern computers have multiple CPU cores, however not all encoders take advantage of this.
If you are planning on running MakeMP3 on a large number of source files, and want to make better
utilisation of your CPU resources, you can use 'find' and 'xargs' to great advantage, e.g.:

    find [src] -iname '*.cue' -print0 | xargs -0 -n 1 -P [threads] MakeMP3 [args]

[src]     - The directory containing your source material
[threads] - The number of simultaneous MakeMP3 instances you want at any one time
[args]    - Your preferred set of command-line options for MakeMP3

Bugs, Known Issues and Planned Features
=======================================

As of MakeMP3 1.3.0, all planned features have now been implemented and the
software is largely reliable. Inevitably, bugs will likely still exist, so if
you discover any unusual behaviour please report it, along with a copy of the
cue sheet MakeMP3 was processing at the time.

Revision History
================
v1.3.0
 *  Added customisable configuration templates, allowing use of different
    encoders. Some template files are provided.
 *  Added timestamp validation. MakeMP3 will not overwrite files that are newer
    than the source cue sheet. Use --force to override this behaviour
 *  Added support for discs mastered with pre-emphasis. If the PRE flag is set,
    additional ffmpeg options are set to apply necessary emphasis to the output.

v1.2.1
 *  Added support for EAC non-compliant cue sheets
 *  Handful of minor bugfixes, including changes to how MakeMP3 writes its own
    metadata. It now only uses the TENC field, leaving TSSE to be written by
    LAME. For details about other bugfixes, please see the commit history.

v1.2.0
 *  Added track-gain support
 *  Improved error-handling

v1.1.0
 *  Added functionality to selectively skip tracks.
 *  Support for explicit track-end timestamps using REM END.
 *  Tweaked artwork code to be more consistent with other metadata, allowing
    REM ARTWORK directives to be specified at the top level and track level.
 *  Permit the use of double quotes in cue sheet directives.

v1.0.0
 *  First release.

Contacting the author
=====================

If you have any feedback, bug reports or feature requests, you can email the
author at <andy@soton.ac.uk> -- I can't make any promises about what further
development or features will go into MakeMP3, but I'm certainly willing to
consider suggestions. Please feel free to submit patches or pull requests.
MakeMP3 is distributed as Free Software in the hopes that it will be useful to
other people. If you find it useful and wish to make a donation, you can do so
via PayPal using the e-mail address listed above.

Licensing
=========

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled "GNU
Free Documentation License".

MakeMP3 is Copyright 2015-2020 Andrew Paul Landells

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
