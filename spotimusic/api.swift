//
//  api.swift
//  spotimusic
//
//  Created by appteve on 20/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//


let EMPTY_QUERY                     = ""

var GLOBAL_USER_ID: NSNumber!
var GLOBAL_CONTROLLER: String!
var isPlayings = Bool()
var APP_BACKGROUND = false


//API constatnt
let X_API_KEY                     =     "?X-API-KEY="
let ENDPOINT_FORGOT_PASS          =     "/endpoint/appusers/reset?email="

//Add Limit
let ADD_LIMIT = "&limit=100000&offset=0"

let BASE_AMAZON_ENDPOINT           =     "https://" + BASE_BACKEND_AMAZON_BUKET + ".s3.amazonaws.com/"
let BASE_BACKEND_AMAZON_SIMAGEF     =     "images/"
let BASE_BACKEND_AMAZON_MUSICF      =     "music/"

//Appuser
let ENDPOINT_USER_UPDATE          =     "/endpoint/appusers/update"
let ENDPOINT_USER_INFO            =     "/endpoint/appusers/userinfo/"
let ENDPOINT_USER_LOGIN           =     "/endpoint/appusers/login/"
let ENDPOINT_USER_REGISTER        =     "/endpoint/appusers/add/"
let ENDPOINT_USER_UPLOAD          =     "/endpoint/appusers/upload/"


//SliderImges

let ENDPOINT_HOME_SLIDER       =     "/endpoint/slider/all?limit=10&offset=0"

//image upload
let ENDPOINT_IMAGE_UPLOAD         =    "/endpoint/appusers/upload/"
let ENDPOINT_IMAGE_UPDATE        =    "/endpoint/appusers/update"


// userTrack
let ENDPOINT_USER_LIKE            =     "/endpoint/usertrack/allusertrack/?id="
let ENDPOINT_TRACK_DISLIKE_ONE    =     "/endpoint/usertrack/delete/?id_track="
let ENDPOINT_ID_USER              =     "&id_user=1"
let ENDPOINT_USER_TRACK_SAVE      =     "/endpoint/usertrack/save"

//artist
let ENDPOINT_SEARCH_ARTIST        =     "/endpoint/artist/search/"

//style
let EBDPOINT_SEARCH_STYLE         =     "/endpoint/style/search"
let ENDPOINT_ALL_STYLE            =     "/endpoint/style/all"


//album
let ENDPOINT_SEARCH_ALBUM         =     "/endpoint/album/search/"

//All media
let ENDPOINT_ALL_MEDIA         =     "/endpoint/videocast/allmediatype?limit=500&offset=0"


let ENDPOINT_AUDIO_QA_DISCOURSES  =    "/endpoint/track/searchquedisc/"
let ENDPOINT_VIDEO_QA_DISCOURSES  =    "/endpoint/videocast/searchquedisc/"


let ENDPOINT_AUDIO_QA_DISCOURSES_LANGUAGE  =    "/endpoint/album/all?limit=10&offset=0"
let ENDPOINT_VIDEO_QA_DISCOURSES_LANGUAGE  =    "/endpoint/album/all?limit=10&offset=0"



//Playlist
let ENDPOINT_ALL_USER_PLIST       =     "/endpoint/playlist/alluserplaylist"
let ENDPOINT_PLIST_ADD            =     "/endpoint/playlist/add/"
let ENDPOINT_PLIST_DELETE         =     "/endpoint/playlist/delete/"

//tracks
let ENDPOINT_SEARCH_TRACK         =     "/endpoint/track/search/"
let ENDPOINT_POST_TRACK_BY_MEDIA_TYPE_ID   =  "/endpoint/track/alltrackbymediatype?id="

let ENDPOINT_ALL_TRACK_BY_STYLE   =     "/endpoint/track/alltrackbystyle?id="

let ENDPOINT_ALL_TRACK_BY_ID      =      "/endpoint/track/trackbyid/"
let ENDPOINT_ALL_TRACK_BY_CATEGORY_SHORT =     "/endpoint/track/alltrackbycategory?id=1"
let ENDPOINT_ALL_TRACK_BY_CATEGORY_LONG =     "/endpoint/track/alltrackbycategory?id=2"


//PlayTrack
let ENDPOINT_ADD_TRACK_IN_PLIST   =     "/endpoint/playtrack/add/"
let ENDPOINT_TRAK_IN_PLIST        =     "/endpoint/playtrack/alltrack/?id="
let ENDPOINT_DELETE_TRACK_IN_PL   =     "/endpoint/playtrack/delete/"


//community

let ENDPOINT_ADD_COMMUNITY  =     "/endpoint/community/addcom"
let ENDPOINT_UPLOAD_COMMUNITY_IMAGE  =   "/endpoint/community/upload/"

let ENDPOINT_GET_ALL_COMMUNITY_BY_PARENT_ID      =    "/av_application/endpoint/community/allcomusrbyprntusrid/1"
let ENDPOINT_ADD_MEMBER_TO_COMMUNITY  =     "/endpoint/community/addusrtocom"
let ENDPOINT_DELETE_MEMBER_FROM_COMMUNITY  = "/endpoint/community/deleteusrfromcom"
let ENDPOINT_GET_ALL_COMMUNITY_BY_USER_ID      =     "/endpoint/community/allcombyusrid/"
let ENDPOINT_GET_ALL_COMMUNITY_NOTIFICATIONS_BY_USER_ID      =     "/endpoint/community/allcombyusrid/"


let ENDPOINT_DELETE_COMMUNITY          =     "/endpoint/community/deletecom"
let ENDPOINT_UPDATE_COMMUNITY          =     "/endpoint/community/updatecom"
let ENDPOINT_COMMUNITY_COMMENT_POST         =     "/endpoint/community/addcomcommentpost"
let ENDPOINT_COMMUNITY_GET_ALL_COMMENT_POST         =     "//endpoint/community/allcommentpostbycommunityid?id="

let ENDPOINT_GET_ALL_POST_BY_COMMUNITYID =     "/endpoint/community/allpostbycommunityid"



//Events
let ENDPOINT_ALL_EVENT_BY_USERID   =     "/endpoint/event/alleventbyusrid/"
let ENDPOINT_ALL_USER_BY_EVENT_ID  =     "/endpoint/event/alluserbyeventid/"
let ENDPOINT_ADD_EVENT             =     "/endpoint/event/addevent"
let ENDPOINT_UPDATE_EVENT          =     "/endpoint/event/updateevent"
let ENDPOINT_UPLOAD_EVENT_IMAGE    =   "/endpoint/event/upload/"




//Meditations
let ENDPOINT_MEDITATION_SEARCH =     "/endpoint/meditation/search/"
let ENDPOINT_MEDITATION_ALL_MEDITAION_BY_MEDIA_TYPE =     "/endpoint/meditation/allmeditationbymediatype?id="
let ENDPOINT_MEDITATION_ALL_MEDITAION_BY_STYLE =     "/endpoint/meditation/allmeditationbystyle?id="
let ENDPOINT_MEDITATION_ALL_MEDITAION_BY_CATEGORY =     "/endpoint/meditation/allmeditationbycategory?id="
let ENDPOINT_MEDITATION_ALL_MEDITAION_BY_ID =     "/endpoint/meditation/meditationbyid/"


//Music

let ENDPOINT_MUSIC_SEARCH =     "/endpoint/music/search/"
let ENDPOINT_MUSIC_ALL_MUSIC_BY_MEDIA_TYPE =     "/endpoint/music/allmusicbymediatype?id="
let ENDPOINT_MUSIC_ALL_MUSIC_BY_STYLE =     "/endpoint/music/allmusicbystyle?id="
let ENDPOINT_MUSIC_ALL_MUSIC_BY_CATEGORY =     "/endpoint/music/allmusicbycategory?id="
let ENDPOINT_MUSIC_ALL_MUSIC_BY_ID =     "/endpoint/music/musicbyid/"

//Interviews

let ENDPOINT_INTERVIEW_SEARCH =     "/endpoint/interview/search/"
let ENDPOINT_INTERVIEW_ALL_INTERVIEW_BY_MEDIA_TYPE =     "/endpoint/interview/allinterviewbymediatype?id="
let ENDPOINT_INTERVIEW_ALL_INTERVIEW_BY_STYLE =     "/endpoint/interview/allinterviewbystyle?id="
let ENDPOINT_INTERVIEW_ALL_INTERVIEW_BY_CATEGORY =  "/endpoint/interview/allinterviewbycategory?id="
let ENDPOINT_INTERVIEW_ALL_INTERVIEW_BY_ID =         "/endpoint/interview/interviewbyid/"

//OSHO Centers
let ENDPOINT_GET_ALL_ASHRAM_BY_STATEID =     "/endpoint/country/getAllAshramByStateId"
let ENDPOINT_GET_ALL_COUNTRY =     "/endpoint/country/getAllCountry"
let ENDPOINT_GET_ALL_STATE =     "/endpoint/country/getAllStateByCountryId"


//Jokes
let ENDPOINT_JOKES_SEARCH     =     "/endpoint/joke/search/"


//New Musics
let ENDPOINT_MEDITATION_MUSIC_SEARCH   =     "/endpoint/music/search/"
let ENDPOINT_BHAJAN_SEARCH             =     "/endpoint/bhajan/search/"
let ENDPOINT_SATSANG_MUSIC_SEARCH      =     "/endpoint/satsang/search/"

//New Interviews
let ENDPOINT_AUDIO_INTERVIEWS_SEARCH   =     "/endpoint/interview/search/"
let ENDPOINT_VIDEO_INTERVIEWS_SEARCH   =     "/endpoint/interviewvideos/search/"

//In app purchase
let ENDPOINT_iOS_ADD_INAPP_SUBSCRIPTION   =     "/endpoint/subscription/iOSaddInAppSubscription"

let iOS_VERSION = "/endpoint/iosversion/all"

//adMob purchase
let   ADMOB_SUBSCRIPTION_STATUS = "/endpoint/Subscription/subscriptionInfoByUserId/"
let   GET_ADMOB_SUBSCRIPTION = "/endpoint/Subscription/addSubscription"
//for IN APP  PURCHASE PRODUCT ID
let IN_APP_PURCHASE_PRODUCT_ID =  "com.askosho.QA"

//recent play songs
let ENDPOINT_RECENT_PLAY_TRACK   =     "/endpoint/recent_playtrack/add/"
let ENDPOINT_GET_RECENT_PLAY_TRACK   =     "/endpoint/recent_playtrack/recent_play/?id="
let ENDPOINT_GET_RECENT_PLAY_TRACKS   = "/endpoint/recent_playtrack/ios_recent_play/?id="

//News
let ENDPOINT_NEWS_SEARCH     =     "/endpoint/news/search"
let ENDPOINT_NEWS_NEWSBYID     =     "/endpoint/news/newsbyid/7"

//MeditationTechnique
let ENDPOINT_SHOWMEDITATIONS     =     "/endpoint/showmeditations/search"
let ENDPOINT_SHOWMEDITATIONSBYID     =     "/endpoint/showmeditations/showmeditationsbyid/"


//Products
let ENDPOINT_PRODUCT_SEARCH     =     "/endpoint/product/search/"
//google AdMob
let BANNAER_ADD_UNIT_ID     =   "ca-app-pub-8432678736813057/7159322649" //"ca-app-pub-1860611326788845/9277680563"
let FULL_ADD_UNIT_ID        =   "ca-app-pub-8432678736813057/5493202972" //"ca-app-pub-1860611326788845/7054486681"


let REWARDED_ADD_UNIT_ID    =   "ca-app-pub-8432678736813057/9395916821"
//"ca-app-pub-1860611326788845/1035873249"

//Test google ads
let TEST_BANNER_ADD_UNIT_ID =   "ca-app-pub-3940256099942544/2934735716"
//let TEST_FULL_ADD_UNIT_ID   =   "ca-app-pub-3940256099942544/5135589807"
let TEST_FULL_ADD_UNIT_ID =  "ca-app-pub-3940256099942544/5135589807"
let TEST_REWARD_ADD_UNIT_ID =   "ca-app-pub-3940256099942544/1712485313"

//Donation Success
let ENDPOINT_DONATION_SUCCESS     =     "/endpoint/appusers/addDonation"

//Save device token
let ENDPOINT_SAVE_DEVICE_TOKEN    =     "/endpoint/appusers/updatetoken"

//Online Magazine
let ENDPOINT_ONLINE_MAGAZINE    =     "/endpoint/onlinemagazines/search"

// event plan
let ENDPOINT_ALL_EVENT_PLAN    =     "/endpoint/event/alleventplans"

//New StripeDonation
let ENDPOINT_STRIPE_DONATION_SUCCESS     =     "/endpoint/Subscription/addDonation/"

