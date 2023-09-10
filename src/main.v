module main

import os
import encoding.hex

/*
RFC3986
reserved    = gen-delims / sub-delims

      gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"

      sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
                  / "*" / "+" / "," / ";" / "="
*/
const(
    reserved = [
				u8(0x21), // '!'
				u8(0x23), // '#'
				u8(0x24), // '$'
				u8(0x25), // '%'
				u8(0x26), // '&'
				u8(0x27), // '\''
				u8(0x28), // '('
				u8(0x29), // ')'
				u8(0x2A), // '*'
                u8(0x2B), // '+'
                u8(0x2C), // ','
				u8(0x2F), // '/'
				u8(0x3A), // ':'
				u8(0x3B), // ';'
				u8(0x3D), // '='
				u8(0x3F), // '?'
				u8(0x40), // '@'
				u8(0x5B), // '['
				u8(0x5D), // ']'
			   ]
)

pub fn encode_byte(b u8) []u8{
    mut ret := []u8{len:1, init:0x25}
    ret << hex.encode([b]).bytes()
    return ret
}

pub fn encode(buf []u8, all bool) string{
    mut ret := []u8{}
    for c in buf{
        if all || (c in reserved) || (c < 0x21) || (c > 0x7E){
            ret << encode_byte(c)
        }else{
            ret << c
        }
    }
    return ret.bytestr()
}

pub fn decode(buf string) []u8{
    mut ret := []u8{}
    mut i := 0
    for i < buf.len {
        if buf[i] == 0x25 {
            ret << hex.decode(buf[i+1..i+3]) or { [u8(0x3F)] }
            i += 3
            continue
        }else{
            ret << buf[i]
            i++
        }
    }
    return ret
}

struct Args{
    decode bool
    all bool
    inputs []string
}

fn help(){
    println("vrl [-d] [-a] [files...]")
    println("\t-d\tDecode mode")
    println("\t-a\tEncode all")
    println("If files are ommited, input is read from stdin")
    exit(0)
}

/*
 * The `cli` package doesn't seem to handle positional arguments 
 */
fn parse_args(argv []string) Args{
    mut decode := false
    mut all := false
    mut inputs := []string{}
    for a in argv[]{
        if a == "-d" {
            decode = true
        }else if a == "-a" {
            all = true
        }else if a[0] == 0x2D {
            help()
        }else{
            inputs << a
        }
    }
    if inputs.len == 0 {
        inputs << "-"
    }
    return Args{
        decode: decode
        all: all
        inputs: inputs
    }
}

fn main() {
    args := parse_args(os.args[1..])
    for i in args.inputs{
        mut buf := []u8{}
        if i == "-" {
            buf = os.get_raw_stdin()
        }else{
            buf = os.read_file_array[u8](i)
        }
        if args.decode {
            print(decode(buf.bytestr()).bytestr())
        }else{
            print(encode(buf, args.all))
        }
    }
}
