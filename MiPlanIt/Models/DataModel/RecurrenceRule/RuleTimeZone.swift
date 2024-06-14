//
//  RuleTimeZone.swift
//  MiPlanIt
//
//  Created by Arun on 11/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension String {
    
    func convertTimeZoneToInterval() -> Int {
        switch self {
            
            case "Dateline Standard Time" : return -12 * 60 * 60
            
            case "Samoa Standard Time" : return 13 * 60 * 60
            
            case "UTC-11" : return -11 * 60 * 60
            
            case "Aleutian Standard Time" : return -10 * 60 * 60
            
            case "Hawaiian Standard Time" : return -10 * 60 * 60
            
            case "Marquesas Standard Time" : return -(9 * 60 * 60 + (30 * 60))
            
            case "Alaskan Standard Time" : return -9 * 60 * 60
            
            case "UTC-09" : return -9 * 60 * 60
            
            case "Yukon Standard Time" : return -7 * 60 * 60
            
            case "Pacific Standard Time (Mexico)" : return -8 * 60 * 60
            
            case "UTC-08" : return -8 * 60 * 60
            
            case "Pacific Standard Time" : return -8 * 60 * 60
            
            case "US Mountain Standard Time" : return -7 * 60 * 60
            
            case "Mountain Standard Time (Mexico)" : return -7 * 60 * 60
            
            case "Mountain Standard Time" : return -7 * 60 * 60
            
            case "Eastern Standard Time (Mexico)" : return -5 * 60 * 60
            
            case "Central America Standard Time" : return -6 * 60 * 60
            
            case "Central Standard Time" : return -6 * 60 * 60
            
            case "Easter Island Standard Time" : return -6 * 60 * 60
            
            case "Central Standard Time (Mexico)" : return -6 * 60 * 60
            
            case "Canada Central Standard Time" : return -6 * 60 * 60
            
            case "SA Pacific Standard Time" : return -5 * 60 * 60
            
            case "Eastern Standard Time" : return -5 * 60 * 60
            
            case "Haiti Standard Time" : return -5 * 60 * 60
            
            case "Cuba Standard Time" : return -5 * 60 * 60
            
            case "US Eastern Standard Time" : return -5 * 60 * 60
            
            case "Turks And Caicos Standard Time" : return -5 * 60 * 60
            
            case "Venezuela Standard Time" : return -4 * 60 * 60
            
            case "Magallanes Standard Time" : return -3 * 60 * 60
            
            case "Paraguay Standard Time" : return -4 * 60 * 60
            
            case "Atlantic Standard Time" : return -4 * 60 * 60
            
            case "Central Brazilian Standard Time" : return -4 * 60 * 60
            
            case "SA Western Standard Time" : return -4 * 60 * 60
            
            case "Pacific SA Standard Time" : return -4 * 60 * 60
            
            case "Newfoundland Standard Time" : return -(3 * 60 * 60 + (30 * 60))
            
            case "Tocantins Standard Time" : return -3 * 60 * 60
            
            case "E. South America Standard Time" : return -3 * 60 * 60
            
            case "SA Eastern Standard Time" : return -3 * 60 * 60
            
            case "Argentina Standard Time" : return -3 * 60 * 60
            
            case "Greenland Standard Time" : return -3 * 60 * 60
            
            case "Montevideo Standard Time" : return -3 * 60 * 60
            
            case "Saint Pierre Standard Time" : return -3 * 60 * 60
            
            case "Bahia Standard Time" : return -3 * 60 * 60
            
            case "UTC-02" : return -2 * 60 * 60
            
            case "Mid-Atlantic Standard Time" : return -2 * 60 * 60
            
            case "Azores Standard Time" : return -1 * 60 * 60
            
            case "Cape Verde Standard Time" : return -1 * 60 * 60
            
            case "UTC" : return 0
            
            case "GMT Standard Time" : return 0 * 60 * 60
            
            case "Greenwich Standard Time" : return 0 * 60 * 60
            
            case "Morocco Standard Time" : return 1 * 60 * 60
            
            case "W. Europe Standard Time" : return 1 * 60 * 60
            
            case "Central Europe Standard Time" : return 1 * 60 * 60
            
            case "Romance Standard Time" : return 1 * 60 * 60
            
            case "Central European Standard Time" : return 1 * 60 * 60
            
            case "W. Central Africa Standard Time" : return 1 * 60 * 60
            
            case "Libya Standard Time" : return 2 * 60 * 60
            
            case "Namibia Standard Time" : return 2 * 60 * 60
            
            case "Jordan Standard Time" : return 2 * 60 * 60
            
            case "GTB Standard Time" : return 2 * 60 * 60
            
            case "Middle East Standard Time" : return 2 * 60 * 60
            
            case "Egypt Standard Time" : return 2 * 60 * 60
            
            case "E. Europe Standard Time" : return 2 * 60 * 60
            
            case "Syria Standard Time" : return 2 * 60 * 60
            
            case "West Bank Standard Time" : return 2 * 60 * 60
            
            case "South Africa Standard Time" : return 2 * 60 * 60
            
            case "FLE Standard Time" : return 2 * 60 * 60
            
            case "Israel Standard Time" : return 2 * 60 * 60
            
            case "Kaliningrad Standard Time" : return 2 * 60 * 60
            
            case "Sudan Standard Time" : return 2 * 60 * 60
            
            case "Turkey Standard Time" : return 3 * 60 * 60
            
            case "Belarus Standard Time" : return 3 * 60 * 60
            
            case "Arabic Standard Time" : return 3 * 60 * 60
            
            case "Arab Standard Time" : return 3 * 60 * 60
            
            case "Russian Standard Time" : return 3 * 60 * 60
            
            case "E. Africa Standard Time" : return 3 * 60 * 60
            
            case "Astrakhan Standard Time" : return 4 * 60 * 60
            
            case "Russia Time Zone 3" : return 4 * 60 * 60
            
            case "Saratov Standard Time" : return 4 * 60 * 60
            
            case "Volgograd Standard Time" : return 4 * 60 * 60
            
            case "Iran Standard Time" : return 3 * 60 * 60 + (30 * 60)
            
            case "Arabian Standard Time" : return 4 * 60 * 60
            
            case "Azerbaijan Standard Time" : return 4 * 60 * 60
            
            case "Mauritius Standard Time" : return 4 * 60 * 60
            
            case "Georgian Standard Time" : return 4 * 60 * 60
            
            case "Caucasus Standard Time" : return 4 * 60 * 60
            
            case "Afghanistan Standard Time" : return 4 * 60 * 60 + (30 * 60)
            
            case "West Asia Standard Time" : return 5 * 60 * 60
            
            case "Ekaterinburg Standard Time" : return 5 * 60 * 60
            
            case "Pakistan Standard Time" : return 5 * 60 * 60
            
            case "Qyzylorda Standard Time" : return 5 * 60 * 60
            
            case "India Standard Time" : return 5 * 60 * 60 + (30 * 60)
            
            case "Sri Lanka Standard Time" : return 5 * 60 * 60 + (30 * 60)
            
            case "Nepal Standard Time" : return 5 * 60 * 60 + (45 * 60)
            
            case "Central Asia Standard Time" : return 6 * 60 * 60
            
            case "Bangladesh Standard Time" : return 6 * 60 * 60
            
            case "Omsk Standard Time" : return 6 * 60 * 60
            
            case "Altai Standard Time" : return 7 * 60 * 60
            
            case "N. Central Asia Standard Time" : return 7 * 60 * 60
            
            case "Tomsk Standard Time" : return 7 * 60 * 60
            
            case "Myanmar Standard Time" : return 6 * 60 * 60 + (30 * 60)
            
            case "SE Asia Standard Time" : return 7 * 60 * 60
            
            case "W. Mongolia Standard Time" : return 7 * 60 * 60
            
            case "North Asia Standard Time" : return 7 * 60 * 60
            
            case "China Standard Time" : return 8 * 60 * 60
            
            case "North Asia East Standard Time" : return 8 * 60 * 60
            
            case "Singapore Standard Time" : return 8 * 60 * 60
            
            case "W. Australia Standard Time" : return 8 * 60 * 60
            
            case "Taipei Standard Time" : return 8 * 60 * 60
            
            case "Ulaanbaatar Standard Time" : return 8 * 60 * 60
            
            case "Transbaikal Standard Time" : return 9 * 60 * 60
            
            case "North Korea Standard Time" : return 9 * 60 * 60
            
            case "Aus Central W. Standard Time" : return 8 * 60 * 60 + (45 * 60)
            
            case "Tokyo Standard Time" : return 9 * 60 * 60
            
            case "Korea Standard Time" : return 9 * 60 * 60
            
            case "Yakutsk Standard Time" : return 9 * 60 * 60
            
            case "Cen. Australia Standard Time" : return 9 * 60 * 60 + (30 * 60)
            
            case "AUS Central Standard Time" : return 9 * 60 * 60 + (30 * 60)
            
            case "E. Australia Standard Time" : return 10 * 60 * 60
            
            case "AUS Eastern Standard Time" : return 10 * 60 * 60
            
            case "West Pacific Standard Time" : return 10 * 60 * 60
            
            case "Tasmania Standard Time" : return 10 * 60 * 60
            
            case "Vladivostok Standard Time" : return 10 * 60 * 60
            
            case "Bougainville Standard Time" : return 11 * 60 * 60
            
            case "Magadan Standard Time" : return 11 * 60 * 60
            
            case "Sakhalin Standard Time" : return 11 * 60 * 60
            
            case "Lord Howe Standard Time" : return 10 * 60 * 60 + (30 * 60)
            
            case "Russia Time Zone 10" : return 11 * 60 * 60
            
            case "Norfolk Standard Time" : return 11 * 60 * 60
            
            case "Central Pacific Standard Time" : return 11 * 60 * 60
            
            case "Russia Time Zone 11" : return 12 * 60 * 60
            
            case "New Zealand Standard Time" : return 12 * 60 * 60
            
            case "UTC12" : return 12 * 60 * 60
            
            case "Fiji Standard Time" : return 12 * 60 * 60
            
            case "Kamchatka Standard Time" : return 12 * 60 * 60
            
            case "Chatham Islands Standard Time" : return 12 * 60 * 60 + (45 * 60)
            
            case "UTC13" : return 13 * 60 * 60
            
            case "Tonga Standard Time" : return 13 * 60 * 60
            
            case "Line Islands Standard Time" : return 14 * 60 * 60
             
            default: return 0
        }
    }
    
    func convertTimeZoneToAppleZone() -> String {
        switch self {
            case "Dateline Standard Time" : return Strings.empty
            
            case "Samoa Standard Time" : return "Pacific/Midway"
            
            case "UTC-11" : return "Pacific/Midway"
            
            case "Aleutian Standard Time" : return "Pacific/Honolulu"
            
            case "Hawaiian Standard Time" : return "Pacific/Honolulu"
            
            case "Marquesas Standard Time" : return "Pacific/Marquesas"
            
            case "Alaskan Standard Time" : return "America/Anchorage"
            
            case "UTC-09" : return "Pacific/Gambier"
            
            case "Yukon Standard Time" : return "America/Chihuahua"
            
            case "Pacific Standard Time (Mexico)" : return "America/Santa_Isabel"
            
            case "UTC-08" : return "Pacific/Pitcairn"
            
            case "Pacific Standard Time" : return "America/Los_Angeles"
            
            case "US Mountain Standard Time" : return "America/Phoenix"
            
            case "Mountain Standard Time (Mexico)" : return "America/Hermosillo"
            
            case "Mountain Standard Time" : return "America/Denver"
            
            case "Eastern Standard Time (Mexico)" : return "America/Cancun"
            
            case "Central America Standard Time" : return "America/Indiana/Knox"
            
            case "Central Standard Time" : return "America/Chicago"
            
            case "Easter Island Standard Time" : return "Pacific/Easter"
            
            case "Central Standard Time (Mexico)" : return "America/Chicago"
            
            case "Canada Central Standard Time" : return "America/Regina"
            
            case "SA Pacific Standard Time" : return "America/Bogota"
            
            case "Eastern Standard Time" : return "America/New_York"
            
            case "Haiti Standard Time" : return "America/Port-au-Prince"
            
            case "Cuba Standard Time" : return "America/Havana"
            
            case "US Eastern Standard Time" : return "America/New_York"
            
            case "Turks And Caicos Standard Time" : return "America/Grand_Turk"
            
            case "Venezuela Standard Time" : return "America/Caracas"
            
            case "Magallanes Standard Time" : return "America/Punta_Arenas"
            
            case "Paraguay Standard Time" : return "America/Asuncion"
            
            case "Atlantic Standard Time" : return "America/Anguilla"
            
            case "Central Brazilian Standard Time" : return "America/Manaus"
            
            case "SA Western Standard Time" : return "America/Manaus"
            
            case "Pacific SA Standard Time" : return "America/Santiago"
            
            case "Newfoundland Standard Time" : return "America/St_Johns"
            
            case "Tocantins Standard Time" : return "America/Sao_Paulo"
            
            case "E. South America Standard Time" : return  "America/Sao_Paulo"
            
            case "SA Eastern Standard Time" : return "America/Cayenne"
            
            case "Argentina Standard Time" : return "America/Argentina/Buenos_Aires"
            
            case "Greenland Standard Time" : return "America/Nuuk"
            
            case "Montevideo Standard Time" : return "America/Montevideo"
            
            case "Saint Pierre Standard Time" : return "America/Miquelon"
            
            case "Bahia Standard Time" : return "America/Bahia"
            
            case "UTC-02" : return "America/Noronha"
            
            case "Mid-Atlantic Standard Time" : return "Atlantic/South_Georgia"
            
            case "Azores Standard Time" : return "Atlantic/Azores"
            
            case "Cape Verde Standard Time" : return "Atlantic/Cape_Verde"
            
            case "UTC" : return "GMT"
            
            case "GMT Standard Time" : return "Europe/London"
        
            case "Greenwich Standard Time" : return "Africa/Monrovia"
            
            case "Morocco Standard Time" : return "Africa/Bangui"
            
            case "W. Europe Standard Time" : return "Europe/Lisbon"
            
            case "Central Europe Standard Time" : return "Europe/Amsterdam"
            
            case "Romance Standard Time" : return "Europe/Brussels"
            
            case "Central European Standard Time" : return "Europe/Amsterdam"
            
            case "W. Central Africa Standard Time" : return "Africa/Lagos"
            
            case "Libya Standard Time" : return "Africa/Tripoli"
            
            case "Namibia Standard Time" : return "Africa/Windhoek"
            
            case "Jordan Standard Time" : return "Asia/Amman"
            
            case "GTB Standard Time" : return "Europe/Athens"
            
            case "Middle East Standard Time" : return "Asia/Gaza"
            
            case "Egypt Standard Time" : return "Africa/Cairo"
            
            case "E. Europe Standard Time" : return "Europe/Bucharest"
            
            case "Syria Standard Time" : return "Asia/Damascus"
            
            case "West Bank Standard Time" : return "Asia/Gaza"
            
            case "South Africa Standard Time" : return "Africa/Johannesburg"
            
            case "FLE Standard Time" : return "Europe/Helsinki"
            
            case "Israel Standard Time" : return "Asia/Jerusalem"
            
            case "Kaliningrad Standard Time" : return "Europe/Kaliningrad"
            
            case "Sudan Standard Time" : return "Africa/Khartoum"
            
            case "Turkey Standard Time" : return "Europe/Istanbul"
            
            case "Belarus Standard Time" : return "Europe/Minsk"
            
            case "Arabic Standard Time" : return "Asia/Aden"
            
            case "Arab Standard Time" : return "Asia/Bahrain"
            
            case "Russian Standard Time" : return "Europe/Moscow"
            
            case "E. Africa Standard Time" : return "Africa/Djibouti"
            
            case "Astrakhan Standard Time" : return "Europe/Astrakhan"
            
            case "Russia Time Zone 3" : return "Europe/Samara"
            
            case "Saratov Standard Time" : return "Europe/Saratov"
            
            case "Volgograd Standard Time" : return "Europe/Volgograd"
            
            case "Iran Standard Time" : return "Asia/Tehran"
            
            case "Arabian Standard Time" : return "Asia/Dubai"
            
            case "Azerbaijan Standard Time" : return "Asia/Baku"
            
            case "Mauritius Standard Time" : return "Indian/Mauritius"
            
            case "Georgian Standard Time" : return "Asia/Tbilisi"
            
            case "Caucasus Standard Time" : return "Asia/Yerevan"
            
            case "Afghanistan Standard Time" : return "Asia/Kabul"
            
            case "West Asia Standard Time" : return "Asia/Ashgabat"
            
            case "Ekaterinburg Standard Time" : return "Asia/Yekaterinburg"
            
            case "Pakistan Standard Time" : return "Asia/Karachi"
            
            case "Qyzylorda Standard Time" : return "Asia/Qyzylorda"
            
            case "India Standard Time" : return "Asia/Calcutta"
            
            case "Sri Lanka Standard Time" : return "Asia/Colombo"
            
            case "Nepal Standard Time" : return "Asia/Kathmandu"
            
            case "Central Asia Standard Time" : return "Asia/Bishkek"
            
            case "Bangladesh Standard Time" : return "Asia/Dhaka"
            
            case "Omsk Standard Time" : return "Asia/Omsk"
            
            case "Altai Standard Time" : return "Asia/Barnaul"
            
            case "N. Central Asia Standard Time" : return "Asia/Novosibirsk"
            
            case "Tomsk Standard Time" : return "Asia/Tomsk"
            
            case "Myanmar Standard Time" : return "Asia/Yangon"
            
            case "SE Asia Standard Time" : return "Asia/Bangkok"
            
            case "W. Mongolia Standard Time" : return "Asia/Hovd"
            
            case "North Asia Standard Time" : return "Asia/Krasnoyarsk"
            
            case "China Standard Time" : return "Asia/Macau"
            
            case "North Asia East Standard Time" : return "Asia/Irkutsk"
            
            case "Singapore Standard Time" : return "Asia/Singapore"
            
            case "W. Australia Standard Time" : return "Australia/Perth"
            
            case "Taipei Standard Time" : return "Asia/Taipei"
            
            case "Ulaanbaatar Standard Time" : return "Asia/Ulaanbaatar"
            
            case "Transbaikal Standard Time" : return "Asia/Chita"
            
            case "North Korea Standard Time" : return "Asia/Pyongyang"
            
            case "Aus Central W. Standard Time" : return "Australia/Eucla"
            
            case "Tokyo Standard Time" : return "Asia/Tokyo"
            
            case "Korea Standard Time" : return "Asia/Seoul"
            
            case "Yakutsk Standard Time" : return "Asia/Yakuts"
            
            case "Cen. Australia Standard Time" : return "Australia/Adelaide"
            
            case "AUS Central Standard Time" : return "Australia/Adelaide"
            
            case "E. Australia Standard Time" : return "Australia/Brisbane"
            
            case "AUS Eastern Standard Time" : return "Australia/Brisbane"
            
            case "West Pacific Standard Time" : return "Pacific/Guam"
            
            case "Tasmania Standard Time" : return "Australia/Hobart"
            
            case "Vladivostok Standard Time" : return "Asia/Vladivostok"
            
            case "Bougainville Standard Time" : return "Pacific/Bougainville"
            
            case "Magadan Standard Time" : return "Asia/Magadan"
            
            case "Sakhalin Standard Time" : return "Asia/Sakhalin"
            
            case "Lord Howe Standard Time" : return "Australia/Lord_Howe"
            
            case "Russia Time Zone 10" : return "Asia/Magadan"
            
            case "Norfolk Standard Time" : return "Pacific/Norfolk"
            
            case "Central Pacific Standard Time" : return "Pacific/Noumea"
            
            case "Russia Time Zone 11" : return "Asia/Kamchatka"
            
            case "New Zealand Standard Time" : return "Antarctica/McMurdo"
            
            case "UTC12" : return "Asia/Kamchatka"
            
            case "Fiji Standard Time" : return "Pacific/Fiji"
            
            case "Kamchatka Standard Time" : return "Asia/Kamchatka"
            
            case "Chatham Islands Standard Time" : return "Pacific/Chatham"
            
            case "UTC13" : return "Pacific/Fakaofo"
            
            case "Tonga Standard Time" : return "Pacific/Tongatapu"
            
            case "Line Islands Standard Time" : return "Pacific/Kiritimati"
             
        default: return self
        }
    }
}
