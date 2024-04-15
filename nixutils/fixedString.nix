{lib}:
{str,len}:
lib.foldl (a: b: a+b) "" (lib.take len (lib.stringToCharacters str))
