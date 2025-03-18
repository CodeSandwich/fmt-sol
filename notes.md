# TODO
- Returning an empty string
- Loop for reading the first arg
- Support for backticks, errors for bad format
- Support for plain `*`
- Support `1*`
- Support `1>*`
- Support `1<*`


`_` ... `([|=|])<$num>[_<char>]`
`[<arg>]u[<$num>][,<char>][;<char>](e|E)[+<char>][#<num>][.[<num>]][:<num>]`
`[<arg>]i[<$num>][+<char>][,<char>][;<char>](e|E)[+<char>][#<num>][.[<num>]][:<num>]`
`[<arg>]u[<$num>][,<char>][;<char>][#<num>][.[<num>]][:<num>]`
`[<arg>]i[<$num>][+<char>][,<char>][;<char>][#<num>][.[<num>]][:<num>]`
`[<arg>](b|B)[<$num>][@<$num>][(?|!)][(][)][(^|+|-|=)]`
`[<arg>](m|M)[<$num>][@<$num>][,<char>[num]]`
`[<arg>](s|S)[<$num>][@<$num>][!]`
`[<arg>]a[(#|^)]`
`[<arg>]y[<char>:<char>]`
`[<arg>]t[<char>]`

<arg> is `[<num>[(>|<)]]`


rounding up for non-E:
if :<num> >= decimals, do nothing
rounder = 10**(decimals - :<num>)
// up = arg % rounder > 0 ? 1 : 0
// round up
arg = (arg + rounder - 1) / rounder
// round nearest
arg = (arg + rounder / 2) / rounder
// round down
arg = arg / rounder
decimals -= :<num>

Handling of E:


# API

For contract:
- calldata % 32 == 4 => an interface call, e.g. formatter.format(abi.encode(...)). Read calldata[calldata[4] + 32]
- calldata % 32 == 0 => a low-level call, e.g. formatter.call(abi.encode(...)). Read calldata[0]

For library:
- formatter.format(abi.encode). Read arg[0].

The library is worth considering only if the compiled bytecode is very small.
Doing calldatacopy to switch from calldata to memory makes sense.
A standalone contract can have helper functions in yul.

# Template

`[arg]*`

The first arg is a template.

If the template value starts with 28 zeros, assume a dyn string, otherwise a bytes32 string.

A continuation? `*` `1*` `2<*` `2>*`

On the stack: char ptr, end ptr = 64 bits? max depth = 5? if end ptr == 0, it's a bytes32 string, round char_ptr down to 32 and keep scanning for the end of string

256 / 4 = 64 = 32 + 32
256 / 5 = 48 + 16 = 24 + 24 + 16

"abc`u``*`", 123, "def `u`", 456

"abc `*$2` `u$1`", 123, "def `u$+1`", 456

# Backtick

``

This is a backtick literal.

# Padding

`_` ... `([|=|])<$num>[_<char>]`
] - align to right. e.g. `_`...`]5` or `_`...`]$2` or `_`...`]$2_0`
[ - align to left. e.g. `_`...`[5` or `_`...`[$2` or `_`...`[$2_0`
= - align to center. E.g. `_`...`=5` or `_`...`=$2` or `_`...`=$2_0`

char is a single byte to pad with. default ` `.

# Arg

"$" - consume the next arg. E.g. "`u/$`" or "`u`"
"$<number>" - peek the number-th argument without consuming it. E.g. "`u/$5`" or "`5u`"
"$<number><" - peek the number-th argument before the currently processed template. E.g. "`u/$2<`" or "`5<u`"
"$<number>>" - peek the number-th argument after the currently processed template. E.g. "`u/$2>`" or "`5>u`"

Arg index OOB error? Impossible except >= 0?

# Char
"?" - "?" unless it's a {. A "single char" is a single UTF-8 codepoint
"{}" - empty string
"{ab}" - "ab"
"`{a}}b}`" - "a}b"

# UTF-8

Length in chars is only needed for padding and strings trimming
We can assume that UTF-8 is valid I guess? It allows free jumps or ignoring continuation bytes which is helpful

# Number

A sequence of characters in range `0`-`9`, may start with an arbitrary number of zeros

# Commons

`<arg>[format]<length><@location><pad>

# Integer

`[<arg>]u[/<$num>][,<char>][;](e|E)[+<char>][#<num>][.[<num>]][:<num>]`
`[<arg>]i[+<char>][/<$num>][,<char>][;](e|E)[+<char>][#<num>][.[<num>]][:<num>]`
`[<arg>]u[/<$num>][,<char>][;][#<num>][.[<num>]][:<num>]`
`[<arg>]i[+<char>][/<$num>][,<char>][;][#<num>][.[<num>]][:<num>]`

/ - default 18, if omitted 0, may be $

.<char> - separator
#<num> - integers precision
.<num:num> - fractions precision




<precision> is:
.<min or .>:<max>
.<min or .>:
.:<max>
.<exact or .>
max and exact may be followed by udiz, nearest is the default

- decimal point - custom, required, custom and required

required decimal point makes sense only for 0:.
`u#6.!`
`u.!:7`
`u#6.!:7`

`u#6..`
`u..:7`
`u#6..:7`

 - integer part - Decimal separator - fractional part

`u#6`
`u.5:7`
`u#6.5:7`
- inside format "" is "?

units = input / 10**decimals

default: 0 min unit digits (! is 0 but with decimal point always printed), exactly decimals, to closest
for exponent: min unit digits is the exponent min digits default: 1, decimals exactly 6, to closest

E rounding probem?
9999 => 9.999e3 =(.2)> 9.99e3 10.00e3 1.00e4
9445 => 9.445e3 =(.2)> 9.45e3
Rounding to zero is just trimming
Rounding from zero going OOB, must do rounding after trimming
Rounding from zero making mantise 10.000


# Bytes

`<arg>(b|B)[<$num>][@<$num>][(?|!)][(][)][^]`

- default - trim if OOB
- `?` - zero-pad if OOB
- `!` - revert if OOB

`@5` from 5th byte
`@-` <width> from the end
`@-5` <width> + 5 from the end

[width]
5>[width]
  [width]<5
    [width]


XOR of multiple hashes? What are the properties?
Forgeable? No, you'd need to preimage at some point
Verifiable? You need all the hashes to verify.
Chainable? If you trust the previous hash - yes?
Orderless unlike hash of hashes.


- skip Y bytes
- limit to X bytes cut on right
- trim zero bytes on right / left / both AFTER limiting scope
- upper/lower case
x print 0x

# String

`(s|S)[<$num>][@<$num>][!]`

zeros are trimmed at the end for `s`, after applying width and @

$num and @num in unicode codepoints or in bytes? Codepoints because otherwise we could cut them.

# Bitmap

`(m|M)<<num><.num>><@<num><.num>>[,<char>[num]]`

, is every 8 bits
01110011
0111 0011

# Address

`a[(#|^)]`
- checksummed or uppercase

# Base64

`(e|E)[<$num>][@<$num>][(?|!)][[(][)][(/|=)]`
- standard OR safe with =

6 bits per char
1 - 2  - 3  - 4 chars
6 - 12 - 18 - 24 bits
0 - 1  - 2  - 3 bytes

byte(lowers, val) | byte(uppoer, val - 32)

data % 3 == 0 => many 4 chars
data % 3 == 1 => many 4 chars + 2 chars (2nd encodes 4 0 bits) + ==
data % 3 == 2 => many 4 chars + 3 chars (3rd encodes 2 0 bits) + =

# Boolean

`y[<char>:<char>]`

# Timestamp

`t<char>`


FORMAT controls the output.  Interpreted sequences are:

  %%   a literal %
  %a   locale's abbreviated weekday name (e.g., Sun)
  %A   locale's full weekday name (e.g., Sunday)
  %b   locale's abbreviated month name (e.g., Jan)
  %B   locale's full month name (e.g., January)
  %c   locale's date and time (e.g., Thu Mar  3 23:05:25 2005)
  %C   century; like %Y, except omit last two digits (e.g., 20)
  %d   day of month (e.g., 01)
  %D   date (ambiguous); same as %m/%d/%y
  %e   day of month, space padded; same as %_d
  %F   full date; like %+4Y-%m-%d
  %g   last two digits of year of ISO week number (ambiguous; 00-99); see %G
  %G   year of ISO week number; normally useful only with %V
  %h   same as %b
  %H   hour (00..23)
  %I   hour (01..12)
  %j   day of year (001..366)
  %k   hour, space padded ( 0..23); same as %_H
  %l   hour, space padded ( 1..12); same as %_I
  %m   month (01..12)
  %M   minute (00..59)
  %n   a newline
  %N   nanoseconds (000000000..999999999)
  %p   locale's equivalent of either AM or PM; blank if not known
  %P   like %p, but lower case
  %q   quarter of year (1..4)
  %r   locale's 12-hour clock time (e.g., 11:11:04 PM)
  %R   24-hour hour and minute; same as %H:%M
  %s   seconds since the Epoch (1970-01-01 00:00 UTC)
  %S   second (00..60)
  %t   a tab
  %T   time; same as %H:%M:%S
  %u   day of week (1..7); 1 is Monday
  %U   week number of year, with Sunday as first day of week (00..53)
  %V   ISO week number, with Monday as first day of week (01..53)
  %w   day of week (0..6); 0 is Sunday
  %W   week number of year, with Monday as first day of week (00..53)
  %x   locale's date (can be ambiguous; e.g., 12/31/99)
  %X   locale's time representation (e.g., 23:13:48)
  %y   last two digits of year (ambiguous; 00..99)
  %Y   year
  %z   +hhmm numeric time zone (e.g., -0400)
  %:z  +hh:mm numeric time zone (e.g., -04:00)
  %::z  +hh:mm:ss numeric time zone (e.g., -04:00:00)
  %:::z  numeric time zone with : to necessary precision (e.g., -04, +05:30)
  %Z   alphabetic time zone abbreviation (e.g., EDT)

By default, date pads numeric fields with zeroes.
The following optional flags may follow '%':

  -  (hyphen) do not pad the field
  _  (underscore) pad with spaces
  0  (zero) pad with zeros
  +  pad with zeros, and put '+' before future years with >4 digits
  ^  use upper case if possible
  #  use opposite case if possible


# Hmm
```
"hello {+3B20@12?[]!}"
'hello `+3B20@12?[]!`'
```
familiar!
collides with JSON

{{ - just {

Internal strings:
``
`` is `

`_` ... `>5_{-=}`
`_` ... `>5_{A}}}`

{_} ... {>5_`-=`}
{_} ... {>5_````}
{_} ... {>5_{-=}}
{_} ... {>5_{-=}}
{_} ... {>5__}

0xC0 = 11000000
0xC1 = 11000001
0xF5 = 11111001
0xFF = 11111111

10FFFF = 0001 0000 1111 1111 1111 1111

1111 0100 	1000 1111 	1011 1111 	1011 1111


10??????
>>6 == 2
& 11000000 == 10000000
