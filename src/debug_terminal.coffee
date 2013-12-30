class DebugTerminal

    echo_char: (char, args) -> console.log(char)

    cuu: (char, args) -> console.log("cuu(#{args})")
    cud: (char, args) -> console.log("cud(#{args})")
    cuf: (char, args) -> console.log("cuf(#{args})")
    cub: (char, args) -> console.log("cub(#{args})")
    cnl: (char, args) -> console.log("cnl(#{args})")
    cpl: (char, args) -> console.log("cpl(#{args})")
    chs: (char, args) -> console.log("chs(#{args})")
    cup: (char, args) -> console.log("cup(#{args})")
    ed:  (char, args) -> console.log("ed(#{args})")
    el:  (char, args) -> console.log("el(#{args})")
    su:  (char, args) -> console.log("su(#{args})")
    sd:  (char, args) -> console.log("sd(#{args})")
    cup: (char, args) -> console.log("cup(#{args})")
    sgr: (char, args) -> console.log("sgr(#{args})")
    dsr: (char, args) -> console.log("dsr(#{args})")
    scp: (char, args) -> console.log("scp(#{args})")
    rsp: (char, args) -> console.log("rsp(#{args})")
    
