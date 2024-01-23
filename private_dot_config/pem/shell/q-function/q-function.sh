[[ $- != *i* ]] && return
#----------------------------------------------------------------------
# utility
#----------------------------------------------------------------------

# Easy extract
function q-extract
{
	if [ -f $1 ] ; then
		case $1 in
		*.tar.bz2)   tar -xvjf $1    ;;
		*.tar.gz)    tar -xvzf $1    ;;
		*.tar.xz)    tar -xvJf $1    ;;
		*.bz2)       bunzip2 $1     ;;
		*.rar)       rar x $1       ;;
		*.gz)        gunzip $1      ;;
		*.tar)       tar -xvf $1     ;;
		*.tbz2)      tar -xvjf $1    ;;
		*.tgz)       tar -xvzf $1    ;;
		*.zip)       unzip $1       ;;
		*.Z)         uncompress $1  ;;
		*.7z)        7z x $1        ;;
		*)           echo "don't know how to extract '$1'..." ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

# easy compress - archive wrapper
function q-compress
{
	if [ -n "$1" ] ; then
		FILE=$1
		case $FILE in
		*.tar) shift && tar -cf $FILE $* ;;
		*.tar.bz2) shift && tar -cjf $FILE $* ;;
		*.tar.xz) shift && tar -cJf $FILE $* ;;
		*.tar.gz) shift && tar -czf $FILE $* ;;
		*.tgz) shift && tar -czf $FILE $* ;;
		*.zip) shift && zip $FILE $* ;;
		*.rar) shift && rar $FILE $* ;;
		esac
	else
		echo "usage: q-compress <foo.tar.gz> ./foo ./bar"
	fi
}

# get current host related info
function q-sysinfo
{
	echo -e "\nYou are logged on ${RED}$HOST"
	echo -e "\nAdditionnal information:$NC " ; uname -a
	echo -e "\n${RED}Users logged on:$NC " ; w -h
	echo -e "\n${RED}Current date :$NC " ; date
	echo -e "\n${RED}Machine stats :$NC " ; uptime
	echo -e "\n${RED}Memory stats :$NC " ; free
	echo -e "\n${RED}Public IP Address :$NC" ; q-myip
	echo -e "\n${RED}Local IP Address :$NC" ; q-ips
}

# get public IP
function q-myip
{
	if command -v curl &> /dev/null; then
		curl ifconfig.co
	elif command -v wget &> /dev/null; then
		wget -qO- ifconfig.co
	fi
}

# get all IPs
function q-ips
{
	case $(uname) in
	Darwin|*BSD)
		local ip=$(ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}')
		;;
	*)
		local ip=$(hostname --all-ip-addresses | tr " " "\n" | grep -v "0.0.0.0" | grep -v "127.0.0.1")
		;;
	esac

	echo "${ip}"
}


# lazy gcc, default outfile: filename_prefix.out, eg: hello.c -> hello.out
function q-gcc
{
	gcc -o ${1%.*}{.out,.${1##*.}} $2 $3 $4 $5
}



# Start an HTTP server from a directory, optionally specifying the port (by paulirish)
function q-server () {
	local port="${1:-8000}"
	exist open && open "http://localhost:${port}/"
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# whois a domain or a URL (by paulirish)
function q-whois () {
	local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
	if [ -z $domain ] ; then
		domain=$1
	fi
	echo "Getting whois record for: $domain …"

	# avoid recursion
                    # this is the best whois server
                                                   # strip extra fluff
    /usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}


function q-littlebig () {
    [[ "$(printf '\01\03' | hexdump)" == *0103* ]] && echo big || echo little
}
# function q-weather {
# 	local city="${1:-xiamen}"
# 	if [ -x "$(which wget)" ]; then
# 		wget -qO- "wttr.in/~${city}"
# 	elif [ -x "$(which curl)" ]; then
# 		curl "wttr.in/~${city}"
# 	fi
# }


# function _colorize_via_pygmentize() {
#     if [ ! -x "$(which pygmentize)" ]; then
#         echo "package \'Pygments\' is not installed!"
#         return -1
#     fi
#
# 	local style="${PYGMENTS_STYLE:-default}"
#
# 	if [[ $TERM != *256color* && $TERM != *rxvt* && $TERM != xterm* ]]; then
# 		style=""
# 	fi
#
#     if [ $# -eq 0 ]; then
# 		if [ -n "$style" ]; then
# 			pygmentize -P style=$style -P tabsize=4 -f terminal256 -g $@
# 		else
# 			pygmentize -P tabsize=4 -g $@
# 		fi
#     fi
#
#     for NAME in $@; do
# 		if [ -n "$style" ]; then
# 			pygmentize -P style=$style -P tabsize=4 -f terminal256 -g "$NAME"
# 		else
# 			pygmentize -P tabsize=4 -g "$NAME"
# 		fi
#     done
# }
