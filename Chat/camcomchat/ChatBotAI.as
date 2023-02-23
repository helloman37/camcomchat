package 
{
    import flash.display.*;
    
    public class ChatBotAI extends flash.display.MovieClip
    {
        public function ChatBotAI()
        {
            brain = new Array();
            matchesArray = new Array();
            lowPriorityWordsArray = new Array();
            topRelevanceMatches = new Array();
            super();
            createMemoryBank();
            return;
        }

        internal function createMemoryBank():*
        {
            var loc1:*=new Array("free", "cost", "costs", "price", "prices", "money", "fee", "monthly", "payment", "pricing", "You can buy the CAMCOM Chat 5 software for only $95 USD and use it on as many websites as you wish.", "high");
            var loc2:*=new Array("integrate", "integration", "integrates", "integrated", "wordpress", "cms", "joomla", "skadate", "osdate", "website", "websites", "member", "database", "register", "registration", "Integration info is here http://www.camcomchat.com/integration.html", "high");
            var loc3:*=new Array("yes", "question", "questions", "ask", "If you have questions, I highly recommend reading our F.A.Q. at http://www.camcomchat.com/faq.html", "high");
            var loc4:*=new Array("webrtc", "media", "server", "servers", "red5", "dedicated", "virtual", "vps", "streaming", "shared", "hosting", "host", "php", "For requirements, please look here http://www.camcomchat.com/requirements.html", "high");
            var loc5:*=new Array("admin", "administration", "administrator", "panel", "kick", "ban", "user", "users", "people", "How the chat room administration works is explained here http://www.camcomchat.com/administration.html", "high");
            var loc6:*=new Array("change", "customize", "customized", "customizable", "customizing", "edit", "modify", "translate", "translation", "resizable", "resized", "resize", "design", "size", "color", "colors", "fonts", "fonts", "language", "languages", "CAMCOM Chat 5 is fully customizable and all editable source files are included. More info here http://www.camcomchat.com/customization.html", "high");
            var loc7:*=new Array("bot", "robot", "chatbot", "I\'m a chat robot! This software enables you to create intelligent chat bots.", "low");
            var loc8:*=new Array("thank", "thanks", "bye", "goodbye", "cya", "Thank you for testing CAMCOM Chat 5!", "low");
            var loc9:*=new Array("user", "users", "people", "connect", "connected", "connection", "maximum", "limit", "max", "The maximum user limit is around 90 on shared web hosting and unlimited on a dedicated server.", "high");
            var loc10:*=new Array("sandy", "hi", "hello", "hey", "hola", "Hi there, do you have any questions about CAMCOM Chat 5?", "low");
            var loc11:*=new Array("from", "I exist only in cyberspace ;)", "low");
            var loc12:*=new Array("open", "sources", "source", "code", "codes", "fla", "as3", "actionscript", "CAMCOM Chat 5 includes all the editable source files.", "high");
            var loc13:*=new Array("upgrade", "upgrades", "upgrading", "update", "updates", "updating", "Existing customers get all CAMCOM Chat updates for free.", "high");
            var loc14:*=new Array("ppv", "ppm", "view", "minute", "minutes", "billing", "per", "CAMCOM Chat 5 has an optional pay per minute billing add-on. You can use it to charge your users money to access the chat. For more info and a demo have a look here http://www.camcomchat.com/pay_per_view_video_chat_features.php", "high");
            var loc15:*=new Array("good", "great", "awesome", "super", "nice", "cool", "Thanks :)", "low");
            var loc16:*=new Array("download", "demo", "trial", "This online demo of CAMCOM Chat 5 lets you test all the main features of the software, such as text messaging as well as video and voice calling. Please give it a try :)", "high");
            var loc17:*=new Array("install", "installation", "setup", "We can provide you with a free installation on your web server.", "high");
            var loc18:*=new Array("video", "voice", "call", "calls", "cam", "webcam", "calling", "You can start a video and voice call by clicking on a user in the right user list. If there is nobody else online, you can simply connect twice to the chat in two browser windows and then video call yourself.", "high");
            var loc19:*=new Array("pussy", "sex", "girls", "girl", "Sorry, this is not a public chat room! This is only a product demo of the CAMCOM Chat 5 software.", "low");
            brain.push(loc1, loc2, loc3, loc4, loc5, loc6, loc7, loc8, loc9, loc10, loc11, loc12, loc13, loc14, loc15, loc16, loc17, loc18, loc19);
            return;
        }

        public function queryAnswer(arg1:String):*
        {
            matchesArray = new Array();
            query = arg1;
            trace(query);
            query = query.toLowerCase();
            var loc1:*=new RegExp("[?|,|.|-|;|:|\"|!|$|%|=|\'|+|*|_|<|>]", "g");
            var loc2:*=query.replace(loc1, "");
            var loc3:*=loc2.split(" ");
            var loc4:*=0;
            while (loc4 < loc3.length) 
            {
                trace(loc3[loc4]);
                ++loc4;
            }
            return matchQuery(loc3);
        }

        internal function matchQuery(arg1:Array):*
        {
            var loc3:*=undefined;
            var loc4:*=0;
            var loc5:*=0;
            var loc6:*=0;
            var loc7:*=NaN;
            var loc8:*=null;
            var loc9:*=0;
            var loc10:*=null;
            var loc1:*=0;
            trace("-> Brain memory items: " + brain.length);
            var loc2:*=0;
            while (loc2 < brain.length) 
            {
                loc3 = new Array();
                loc4 = 0;
                while (loc4 < brain[loc2].length - 2) 
                {
                    loc5 = 0;
                    while (loc5 < arg1.length) 
                    {
                        if (arg1[loc5] == brain[loc2][loc4]) 
                        {
                            ++loc1;
                            loc3.push(brain[loc2][loc4]);
                        }
                        ++loc5;
                    }
                    ++loc4;
                }
                trace("-> Matches | Memory " + (loc2 + 1) + ": " + loc1);
                if (loc1 > 0) 
                {
                    matchesArray.push({"id":int(loc2), "count":int(loc1), "words":loc3});
                }
                loc1 = 0;
                ++loc2;
            }
            if (matchesArray.length > 0) 
            {
                matchesArray.sortOn(["count", "id"], [Array.DESCENDING, Array.NUMERIC]);
                loc6 = 0;
                while (loc6 < matchesArray.length) 
                {
                    trace(matchesArray[loc6].id + " : " + matchesArray[loc6].count + " : " + matchesArray[loc6].words[0]);
                    ++loc6;
                }
                loc7 = matchesArray[0].count;
                trace("-> Max matches: " + loc7);
                if (matchesArray.length > 1) 
                {
                    topRelevanceMatches = new Array();
                    topRelevanceMatches.push(matchesArray[0]);
                    if (matchesArray.length >= 2) 
                    {
                        if (loc7 == matchesArray[1].count) 
                        {
                            topRelevanceMatches.push(matchesArray[1]);
                        }
                    }
                    if (matchesArray.length >= 3) 
                    {
                        if (loc7 == matchesArray[2].count) 
                        {
                            topRelevanceMatches.push(matchesArray[2]);
                        }
                    }
                    trace("Top relevance matches: " + topRelevanceMatches.length);
                    loc8 = new Array();
                    if (topRelevanceMatches.length > 1) 
                    {
                        loc9 = 0;
                        while (loc9 < topRelevanceMatches.length) 
                        {
                            trace(brain[topRelevanceMatches[loc9].id][(brain[topRelevanceMatches[loc9].id].length - 1)]);
                            if (brain[topRelevanceMatches[loc9].id][(brain[topRelevanceMatches[loc9].id].length - 1)] != "low") 
                            {
                                loc8.push(topRelevanceMatches[loc9]);
                            }
                            ++loc9;
                        }
                        if (loc8.length == 0) 
                        {
                            loc8.push(topRelevanceMatches[0]);
                        }
                    }
                    else 
                    {
                        loc8.push(topRelevanceMatches[0]);
                    }
                    trace("Final matches: " + loc8.length);
                    if (loc8.length == 1) 
                    {
                        return brain[loc8[0].id][brain[loc8[0].id].length - 2];
                    }
                    if (loc8.length == 2) 
                    {
                        return loc10 = brain[loc8[0].id][brain[loc8[0].id].length - 2] + " - " + brain[loc8[1].id][brain[loc8[1].id].length - 2];
                    }
                    return "I\'m not sure I understand your question. Can you be more specific? I also recommend reading our F.A.Q. at http://www.camcomchat.com/faq.html";
                }
                return brain[matchesArray[0].id][brain[matchesArray[0].id].length - 2];
            }
            return "nothing";
        }

        internal var query:String;

        internal var brain:Array;

        internal var matchesArray:Array;

        internal var lowPriorityWordsArray:Array;

        internal var topRelevanceMatches:Array;
    }
}
