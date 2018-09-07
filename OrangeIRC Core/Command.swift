// This file of part of the Swift IRC client framework OrangeIRC Core.
//
// Copyright © 2016 Andrew Hyatt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

/// IRC Commands
///
/// https://www.alien.net.au/irc/irc2numerics.html
internal struct Command {
    
    static let JOIN = "JOIN"
    static let NICK = "NICK"
    static let PART = "PART"
    static let PASS = "PASS"
    static let PING = "PING"
    static let PONG = "PONG"
    static let QUIT = "QUIT"
    static let USER = "USER"
    static let ERROR = "ERROR"
    
    static let WHOIS = "WHOIS"
    
    static let NOTICE = "NOTICE"
    static let PRIVMSG = "PRIVMSG"
    static let IDENTIFY = "IDENTIFY"
    
    static let VERSION = "VERSION"
    static let TIME = "TIME"
    
    static let LIST = "LIST"
    
    static let MODE = "MODE"
    
    static let KICK = "KICK"
    
    struct Reply {
        
        static let WELCOME = "001"
        static let YOURHOST = "002"
        static let CREATED = "003"
        static let MYINFO = "004"
        static let BOUNCE = "005"
        
        static let YOURID = "042"
        
        static let STATSDLINE = "250"
        static let LUSERCLIENT = "251"
        static let LUSEROP = "252"
        static let LUSERUNKNOWN = "253"
        static let LUSERCHANNELS = "254"
        static let LUSERME = "255"
        static let ADMINME = "256"
        
        static let LOCALUSERS = "265"
        static let GLOBALUSERS = "266"
        
        static let USERHOST = "302"
        static let ISON = "303"
        
        static let AWAY = "301"
        static let UNAWAY = "305"
        static let NOWAWAY = "306"
        
        static let WHOISUSER = "311"
        static let WHOISSERVER = "312"
        static let WHOISOPERATOR = "313"
        static let WHOISIDLE = "317"
        static let ENDOFWHOIS = "318"
        static let WHOISCHANNELS = "319"
        static let WHOWASUSER = "314"
        static let ENDOFWHOWAS = "369"
        
        static let LISTSTART = "321"
        static let LIST = "322"
        static let LISTEND = "323"
        
        static let UNIQOPIS = "325"
        static let CHANNELMODEIS = "324"
        
        static let CHANNEL_URL = "328"
        
        static let WHOISACCOUNT = "330"
        
        static let NOTOPIC = "331"
        static let TOPIC = "332"
        
        static let INVITING = "341"
        static let SUMMONING = "342"
        
        static let INVITELIST = "346"
        static let ENDOFINVITELIST = "346"
        
        static let EXCEPTLIST = "348"
        static let ENDOFEXCEPTLIST = "349"
        
        static let VERSION = "351"
        
        static let WHOREPLY = "352"
        static let ENDOFWHO = "315"
        
        static let NAMREPLY = "353"
        static let ENDOFNAMES = "366"
        
        static let MOTDSTART = "375"
        static let MOTD = "372"
        static let ENDOFMOTD = "376"
        
        static let WHOISHOST = "378"
        
    }
    
    struct Error {
        
        static let NOSUCHNICK = "401"
        static let NOSUCHSERVER = "402"
        static let NOSUCHCHANNEL = "403"
        static let CANNOTSENDTOCHAN = "404"
        static let TOOMANYCHANNELS = "405"
        static let WASNOSUCHNICK = "406"
        static let TOOMANYTARGETS = "407"
        static let NOSUCHSERVICE = "408"
        static let NOORIGIN = "409"
        static let NORECIPIENT = "411"
        static let NOTEXTTOSEND = "412"
        static let NOTOPLEVEL = "413"
        static let WILDTOPLEVEL = "414"
        static let BADMASK = "415"
        static let UNKNOWNCOMMAND = "421"
        static let NOMOTD = "422"
        static let NOADMININFO = "423"
        static let FILERROR = "424"
        static let NONICKNAMEGIVEN = "431"
        static let NICKNAMEINUSE = "433"
        static let NICKCOLLISION = "436"
        static let UNAVAILRESOURCE = "437"
        static let USERNOTINCHANNEL = "441"
        static let NOTONCHANNEL = "442"
        static let USERONCHANNEL = "443"
        static let NOLOGIN = "444"
        static let SUMMONDISABLED = "445"
        static let USERSDISABLED = "446"
        static let NOTREGISTERED = "451"
        static let NEEDMOREPARAMS = "461"
        static let ALREADYREGISTERED = "462"
        static let NOPERMFORHOST = "463"
        static let PASSWDMISMATCH = "464"
        static let YOUREBANNEDCREEP = "465"
        static let YOUWILLBEBANNED = "466"
        static let KEYSET = "467"
        static let CHANNELISFULL = "471"
        static let UNKNOWNMODE = "472"
        static let INVITEONLYCHAN = "473"
        static let BANNEDFROMCHAN = "474"
        static let BADCHANNELKEY = "475"
        static let BADCHANMASK = "476"
        static let NOCHANMODES = "477"
        static let BANLISTFULL = "478"
        static let NOPRIVILEGES = "481"
        static let CHANOPRIVSNEEDED = "482"
        static let CANTKILLSERVER = "483"
        static let RESTRICTED = "484"
        static let UNIQOPPRIVSNEEDED = "485"
        static let NOOPERHOST = "491"
        static let UMODEUNKNOWNFLAG = "501"
        static let USERSDONTMATCH = "502"
        
    }
    
    struct Services {
        
        static let NickServ = "NickServ"
    }
    
}
