#!/usr/bin/env zsh

emulate -L zsh -o extendedglob -o typesetsilent -o rcquotes -o noautopushd

[[ $PWD != */pm-perf-test ]] && {
    print "The script has to be ran from the \`pm-perf-test' directory"
    return 1
}

typeset -g __thepwd=$PWD
trap "cd $__thepwd; unset __thepwd" EXIT
trap "cd $__thepwd; unset __thepwd; return 1" INT

mkdir -p results

print -P "%F{160}Removing previous plugins and results…%f"

rm -rf **/(_zplug|_zgen|_zplugin)(DN) results/*.txt(DN)

print -P "%F{160}done%f"

print -P "\n%F{160}============================%f"
print -P "%F{160}Measuring installation time…%f"
print -P "%F{160}============================%f"

for i in zplug zgen zplugin*~*omz; do
    print -P "\n%F{154}=== 3 results for %F{140}$i%F{154}: ===%f"

    cd -q $i

    ZDOTDIR=$PWD zsh -i -c exit |& grep '\[zshrc\]' | tee -a ../results/$i-inst.txt
    rm -rf _(zplug|zgen|zplugin)
    ZDOTDIR=$PWD zsh -i -c exit |& grep '\[zshrc\]' | tee -a ../results/$i-inst.txt
    rm -rf _(zplug|zgen|zplugin)
    ZDOTDIR=$PWD zsh -i -c exit |& grep '\[zshrc\]' | tee -a ../results/$i-inst.txt

    cd -q $__thepwd
done

print -P "\n%F{160}============================%f"
print -P "%F{160}Measuring startup-time time…%f"
print -P "%F{160}============================%f"

for i in zplug zgen zplugin*~(*omz|*txt); do
    print -P "\n%F{154}=== 10 results for %F{140}$i%F{154}: ===%f"

    cd -q $i

    # Warmup
    print -P "\n%F{10}(WARMUP…)%f"
    repeat 20 {
        ZDOTDIR=$PWD zsh -i -c exit &>/dev/null
    }

    # The proper test
    repeat 10 {
        ZDOTDIR=$PWD zsh -i -c exit |& grep '\[zshrc\]' | tee -a ../results/$i.txt
    }

    cd -q $__thepwd
done
