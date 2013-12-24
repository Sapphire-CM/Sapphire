# encoding: UTF-8

$tutors = [
  { name: 'Alexander', email: 'inm-t1-alexander@iicm.edu' },
  { name: 'Lukas',     email: 'inm-t2-lukas@iicm.edu' },
  { name: 'Dominik',   email: 'inm-t3-dominik@iicm.edu' },
  { name: 'Gerald',    email: 'inm-t4-gerald@iicm.edu' },
  { name: 'Matthias',  email: 'inm-t5-matthias@iicm.edu' },
  { name: 'Thomas',    email: 'inm-t6-thomas@iicm.edu' },
]

$famous_persons = []
$famous_persons << [
  { name: 'Charles Leiserson',    acm: { page_count: 12, hash: '91deabdb500960d9a7f40f832690b68e' }, ieee: { page_count: 12, hash: 'f14465277dc004b4ea649c32b2ba60e0' } },
  { name: 'Piotr Indyk',          acm: { page_count:  4, hash: '3557ddbc86bb5ea46ec705b9937fce2e' }, ieee: { page_count: 10, hash: '4855a70829b5cd682b7f66e7f320990e' } },
  { name: 'Saman Amarasinghe',    acm: { page_count: 12, hash: '74fe2c5487f9709213f2cb74a9266c25' }, ieee: { page_count: 12, hash: '88cf11c48fdb0b511414e5af6aed0b07' } },
  { name: 'Barbara Liskov',       acm: { page_count: 14, hash: '68721ecb7e909b78c18089d039bf307a' }, ieee: { page_count: 14, hash: 'fc0fdf39a59878a2784732d0fd112c8b' } },
  { name: 'Robert Gallager',      acm: { page_count: 12, hash: '1e22f1dc072a845e5af59bb8c358903f' }, ieee: { page_count: 12, hash: '30a2f7788846e52f05c535da30b478e9' } },
]

$famous_persons << [
  { name: 'David Dill',           acm: { page_count:  8, hash: '2a6a380455061abe632b30077c69b3a6' }, ieee: { page_count:  7, hash: '44c6d26edac175ce98bf2a29b80eb8e7' } },
  { name: 'Michael Genesereth',   acm: { page_count:  9, hash: 'a36fad259b633b752730b2eefacc71d5' }, ieee: { page_count:  5, hash: '5c265a98278592b298801453ce235185' } },
  { name: 'Ronald Fedkiw',        acm: { page_count: 10, hash: '915252cb3836a54cb682cc0f3f9c4a2d' }, ieee: { page_count: 12, hash: 'dca8d03618b79b30c47ae15966effd6e' } },
  { name: 'Hector Garcia-Molina', acm: { page_count:  9, hash: '0d4825a0df9496c7a532ee8a233ee7d5' }, ieee: { page_count: 14, hash: '22f416fae108bca65872cf92c23272da' } },
  { name: 'Gill Bejerano',        acm: { page_count:  9, hash: 'f8a4aea79b779d5e365901e402eb0c67' }, ieee: { page_count:  8, hash: '370423eb579661d30853e6872d77ea50' } },
]

$famous_persons << [
  { name: 'Jaime Carbonell',      acm: { page_count:  4, hash: '80e3eae73d75d1a6db7ba766d1c856da' }, ieee: { page_count:  6, hash: 'a36735e56801babf34dbba88df273310' } },
  { name: 'Robert Frederking',    acm: { page_count:  4, hash: 'b2732b798f4446c7c751716def7ffc2a' }, ieee: { page_count:  5, hash: 'a286dea20069c6d3ec8044f7457147d3' } },
  { name: 'Frank Pfenning',       acm: { page_count: 12, hash: 'fd7b8583ced4489ee9225ecc03d6e113' }, ieee: { page_count: 16, hash: '254479b3e47e4afec56f4cffdd4521fa' } },
  { name: 'Guy Blelloch',         acm: { page_count: 12, hash: 'b789e12720de75d697a9792ff5a54e14' }, ieee: { page_count: 11, hash: '18533577458c2969b25ef8dba0660bae' } },
  { name: 'John Lafferty',        acm: { page_count:  8, hash: 'cb67ef4eb1faa1b1e632419ee3fb6fbc' }, ieee: { page_count:  5, hash: 'bd91e32f6db6a3a639eed9f73e50c5ee' } },
]

$famous_persons << [
  { name: 'Brian Barsky',         acm: { page_count: 12, hash: '7f5b59ad6ddca5295b63445a2a79a857' }, ieee: { page_count:  8, hash: '6897a5642eefc2e374520177443cb887' } },
  { name: 'Maneesh Agrawala',     acm: { page_count: 10, hash: '7c4c3a5034027f990542f2fdb204ef6d' }, ieee: { page_count:  8, hash: '32abc832939a2339e17ace5ce2f08c29' } },
  { name: 'Eric Brewer',          acm: { page_count:  8, hash: 'f518f3634a5714680e1dd4843d096187' }, ieee: { page_count:  7, hash: 'd94d99988c0293c62880b87fbdabf37e' } },
  { name: 'David Culler',         acm: { page_count: 12, hash: '1c171bac1368219fcdc8f624f2008ee3' }, ieee: { page_count: 10, hash: 'c9cd901df285b90035bc14be35ca8901' } },
  { name: 'David Patterson',      acm: { page_count: 12, hash: '5393464b495ccd9789a84cbbba6abbc2' }, ieee: { page_count:  6, hash: 'eed7561e331f1aaf0cbfae0f24ed0629' } },
]

$famous_persons << [
  { name: 'Torsten Hoefler',      acm: { page_count:  6, hash: '44f610bc8f0c2a22975e8ec7f2a6b5fa' }, ieee: { page_count:  8, hash: '4425b7d9b879e95b58cf4f5049df286a' } },
  { name: 'Markus Püschel',       acm: { page_count:  9, hash: 'f808a4307d2f52cb22fb97c389b9cc28' }, ieee: { page_count: 15, hash: 'e7fe8cce8a46951fbd7f91d6e8e67b0e' } },
  { name: 'Moira Norrie',         acm: { page_count: 10, hash: '51ee443dc4c04de5cb67b72cbc3867a0' }, ieee: { page_count: 13, hash: '01641514e99c6e5a9d3f4d04c87f23fb' } },
  { name: 'Emo Welzl',            acm: { page_count: 10, hash: '2b0d13c7e8fad6756f788d20e607517f' }, ieee: { page_count:  9, hash: '5bceb85228b19d6d31c9aef328e63983' } },
  { name: 'Friedemann Mattern',   acm: { page_count: 10, hash: 'f3b985b92b2bbe83157667444d905903' }, ieee: { page_count:  8, hash: 'd890bcebd0f6e2502a0865ce32c77afb' } },
]

$famous_persons << [
  { name: 'Andrew Davison',       acm: { page_count: 10, hash: '0bcc9b8ce5b91dc0a362201ac27db975' }, ieee: { page_count:  8, hash: '689fcad8ff0b9edd101efc31ab8dadc1' } },
  { name: 'Sophia Drossopoulou',  acm: { page_count:  7, hash: '70d2e879d796c3417c81980d5ea64184' }, ieee: { page_count: 10, hash: 'd7cebb5ec8f3caa70d2e56a8892de101' } },
  { name: 'Chris Hankin',         acm: { page_count: 42, hash: 'b617e2ed7d52692721571600364f5bca' }, ieee: { page_count: 14, hash: '19c6422af9695f696167b490d9608c5f' } },
  { name: 'Maja Pantic',          acm: { page_count:  4, hash: '25c7397faad3b1266aded8409ddb7a80' }, ieee: { page_count:  8, hash: '60c70da41ec7560fb1545d44035b7d64' } },
  { name: 'Alexander Wolf',       acm: { page_count:  6, hash: 'e1aea08d43d5e27c3c66d85623470ecb' }, ieee: { page_count:  4, hash: '496a0c5a99d2018b50aeaa0cd5ae991b' } },
]

