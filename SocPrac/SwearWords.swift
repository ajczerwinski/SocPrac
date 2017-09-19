//
//  SwearWords.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 9/18/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

// Bad language filter

import Foundation

struct SwearWords {
    
    static let hashedSwearWords =
    
    ["NHI1ZQ==", "NWgxdA==", "NWhpdA==", "YV9zX3M=", "YTU1", "YW5hbA==", "YW51cw==", "YXI1ZQ==", "YXJyc2U=", "YXJzZQ==", "YXNzLWZ1Y2tlcg==", "YXNz", "YXNzYnV0dA==", "YXNzY2xvd24=", "YXNzZXM=", "YXNzZnVja2Vy", "YXNzZnVra2E=", "YXNzaGF0", "YXNzaG9sZQ==", "YXNzaG9sZXM=", "YXNzd2hvbGU=", "YiF0Y2g=", "YjAwYnM=", "YjE3Y2g=", "YjF0Y2g=", "YmFsbGJhZw==", "YmFsbHNhY2s=", "YmFzdGFyZA==", "YmVhc3RpYWw=", "YmVhc3RpYWxpdHk=", "YmVsbGVuZA==", "YmVzdGlhbA==", "YmVzdGlhbGl0eQ==", "YmkrY2g=", "YmlhdGNo", "Yml0Y2g=", "Yml0Y2hlcg==", "Yml0Y2hlcnM=", "Yml0Y2hlcw==", "Yml0Y2hpbg==", "Yml0Y2hpbmc=", "Qml0Y2hudWdnZXQ=", "Ymxvb2R5", "Ymxvd2pvYg==", "Ymxvd2pvYg==", "Ymxvd2pvYnM=", "Ym9pb2xhcw==", "Ym9sbG9jaw==", "Ym9sbG9r", "Ym9uZXI=", "Ym9vYg==", "Ym9vYnM=", "Ym9vb2Jz", "Ym9vb29icw==", "Ym9vb29vYnM=", "Ym9vb29vb29icw==", "YnJlYXN0cw==", "YnVjZXRh", "YnVnZ2Vy", "YnVt", "YnVubnlmdWNrZXI=", "YnV0dA==", "YnV0dGhvbGU=", "YnV0dG11Y2g=", "YnV0dHBsdWc=", "YzBjaw==", "YzBja3N1Y2tlcg==", "Y2FycGV0bXVuY2hlcg==", "Y2F3aw==", "Y2hpbms=", "Y2lwYQ==", "Y2wxdA==", "Y2xpdA==", "Y2xpdG9yaXM=", "Y2xpdHM=", "Y2x1c3RlcmZ1Y2s=", "Y251dA==", "Y29jay1zdWNrZXI=", "Y29jaw==", "Y29ja2ZhY2U=", "Y29ja2hlYWQ=", "Y29ja21hc3Rlcg==", "Y29ja211bmNo", "Y29ja211bmNoZXI=", "Y29ja3M=", "Y29ja3N1Y2s=", "Y29ja3N1Y2tlZA==", "Y29ja3N1Y2tlcg==", "Y29ja3N1Y2tpbmc=", "Y29ja3N1Y2tz", "Y29ja3N1a2E=", "Y29ja3N1a2th", "Y29r", "Y29rbXVuY2hlcg==", "Y29rc3Vja2E=", "Y29vbg==", "Y3JhcA==", "Y3Vt", "Y3VtZ3V6emxlcg==", "Y3VtbWVy", "Y3VtbWluZw==", "Y3Vtcw==", "Y3Vtc2hvdA==", "Y3VuaWxpbmd1cw==", "Y3VuaWxsaW5ndXM=", "Y3VubmlsaW5ndXM=", "Y3VudA==", "Y3VudGxpY2s=", "Y3VudGxpY2tlcg==", "Y3VudGxpY2tpbmc=", "Y3VudHM=", "Y3lhbGlz", "Y3liZXJmdWM=", "Y3liZXJmdWNr", "Y3liZXJmdWNrZWQ=", "Y3liZXJmdWNrZXI=", "Y3liZXJmdWNrZXJz", "Y3liZXJmdWNraW5n", "ZDFjaw==", "ZGFtbg==", "ZGljaw==", "ZGlja2JhZw==", "ZGlja2hlYWQ=", "ZGlsZG8=", "ZGlsZG9z", "ZGluaw==", "ZGlua3M=", "ZGlyc2E=", "ZGxjaw==", "ZG9nLWZ1Y2tlcg==", "ZG9nZ2lu", "ZG9nZ2luZw==", "ZG9ua2V5cmliYmVy", "ZG9vc2g=", "ZG91Y2hl", "ZHVjaGU=", "ZHlrZQ==", "ZWphY3VsYXRl", "ZWphY3VsYXRlZA==", "ZWphY3VsYXRlcw==", "ZWphY3VsYXRpbmc=", "ZWphY3VsYXRpbmdz", "ZWphY3VsYXRpb24=", "ZWpha3VsYXRl", "Zl91X2Nfaw==", "ZjRubnk=", "ZmFn", "ZmFnZ2luZw==", "ZmFnZ2l0dA==", "ZmFnZ290", "ZmFnZ3M=", "ZmFnb3Q=", "ZmFnb3Rz", "ZmFncw==", "ZmFubnk=", "ZmFubnlmbGFwcw==", "ZmFubnlmdWNrZXI=", "ZmFueXk=", "ZmF0YXNz", "ZmN1aw==", "ZmN1a2Vy", "ZmN1a2luZw==", "ZmVjaw==", "ZmVja2Vy", "ZmVsY2hpbmc=", "ZmVsbGF0ZQ==", "ZmVsbGF0aW8=", "ZmluZ2VyZnVjaw==", "ZmluZ2VyZnVja2Vk", "ZmluZ2VyZnVja2Vy", "ZmluZ2VyZnVja2Vycw==", "ZmluZ2VyZnVja2luZw==", "ZmluZ2VyZnVja3M=", "ZmlzdGZ1Y2s=", "ZmlzdGZ1Y2tlZA==", "ZmlzdGZ1Y2tlcg==", "ZmlzdGZ1Y2tlcnM=", "ZmlzdGZ1Y2tpbmc=", "ZmlzdGZ1Y2tpbmdz", "ZmlzdGZ1Y2tz", "Zmxhbmdl", "Zm9vaw==", "Zm9va2Vy", "ZnVjaw==", "ZnVjaw==", "ZnVja2E=", "ZnVja2Vk", "ZnVja2Vy", "ZnVja2Vy", "ZnVja2Vycw==", "ZnVja2hlYWQ=", "ZnVja2hlYWRz", "ZnVja2lu", "ZnVja2luZw==", "ZnVja2luZ3M=", "ZnVja2luZ3NoaXRtb3RoZXJmdWNrZXI=", "ZnVja21l", "ZnVja251Z2dldA==", "ZnVja3M=", "ZnVja3N0aWNr", "ZnVja3RhcmQ=", "ZnVja3RydW1wZXQ=", "ZnVja3doaXQ=", "ZnVja3dpdA==", "ZnVkZ2VwYWNrZXI=", "ZnVkZ2VwYWNrZXI=", "ZnVr", "ZnVrZXI=", "ZnVra2Vy", "ZnVra2lu", "ZnVrcw==", "ZnVrd2hpdA==", "ZnVrd2l0", "ZnV4", "ZnV4MHI=", "Z2FuZ2Jhbmc=", "Z2FuZ2JhbmdlZA==", "Z2FuZ2Jhbmdz", "Z2F5bG9yZA==", "Z2F5c2V4", "Z29hdHNl", "Z29kLWRhbQ==", "Z29kLWRhbW5lZA==", "R29k", "Z29kZGFtbg==", "Z29kZGFtbmVk", "aGFyZGNvcmVzZXg=", "aGVsbA==", "aGVzaGU=", "aG9hcg==", "aG9hcmU=", "aG9lcg==", "aG9tbw==", "aG9yZQ==", "aG9ybmllc3Q=", "aG9ybnk=", "aG9yc2VmdWNrZXI=", "aG90c2V4", "amFjay1vZmY=", "amFja29mZg==", "amFw", "amVyay1vZmY=", "amlzbQ==", "aml6", "aml6bQ==", "aml6eg==", "anVpY2ViYWc=", "a2F3aw==", "a25vYg==", "a25vYmVhZA==", "a25vYmVk", "a25vYmVuZA==", "a25vYmhlYWQ=", "a25vYmpvY2t5", "a25vYmpvY2tleQ==", "a29jaw==", "a29uZHVt", "a29uZHVtcw==", "a3Vt", "a3VtbWVy", "a3VtbWluZw==", "a3Vtcw==", "a3VuaWxpbmd1cw==", "bDNpK2No", "bDNpdGNo", "bGFiaWE=", "bG1mYW8=", "bHVzdA==", "bHVzdGluZw==", "bTBmMA==", "bTBmbw==", "bTQ1dGVyYmF0ZQ==", "bWE1dGVyYjg=", "bWE1dGVyYmF0ZQ==", "bWFzb2NoaXN0", "bWFzdGVyLWJhdGU=", "bWFzdGVyYjg=", "bWFzdGVyYmF0Kg==", "bWFzdGVyYmF0Mw==", "bWFzdGVyYmF0ZQ==", "bWFzdGVyYmF0aW9u", "bWFzdGVyYmF0aW9ucw==", "bWFzdHVyYmF0ZQ==", "bW5mbg==", "bWZubW4=", "bWZubW5mbg==", "bW8tZm8=", "bW9mMA==", "bW9mbw==", "bW90aGFmdWNr", "bW90aGFmdWNrYQ==", "bW90aGFmdWNrYXM=", "bW90aGFmdWNrYXo=", "bW90aGFmdWNrZWQ=", "bW90aGFmdWNrZXI=", "bW90aGFmdWNrZXJz", "bW90aGFmdWNraW4=", "bW90aGFmdWNraW5n", "bW90aGFmdWNraW5ncw==", "bW90aGFmdWNrcw==", "bW90aGVyZnVjaw==", "bW90aGVyZnVja2Vk", "bW90aGVyZnVja2Vy", "bW90aGVyZnVja2Vycw==", "bW90aGVyZnVja2lu", "bW90aGVyZnVja2luZw==", "bW90aGVyZnVja2luZ3M=", "bW90aGVyZnVja2th", "bW90aGVyZnVja3M=", "bXVmZg==", "bXV0aGE=", "bXV0aGFmZWNrZXI=", "bXV0aGFmdWNra2Vy", "bXV0aGVy", "bXV0aGVyZnVja2Vy", "bjFnZ2E=", "bjFnZ2Vy", "bmF6aQ==", "bmlnZzNy", "bmlnZzRo", "bmlnZ2E=", "bmlnZ2Fo", "bmlnZ2Fz", "bmlnZ2F6", "bmlnZ2Vy", "bmlnZ2Vycw==", "bm9i", "bm9iaGVhZA==", "bm9iam9ja3k=", "bm9iam9ja2V5", "bnVtYm51dHM=", "bnV0c2Fjaw==", "b3JnYXNpbQ==", "b3JnYXNpbXM=", "b3JnYXNt", "b3JnYXNtcw==", "cDBybg==", "cGF3bg==", "cGVja2Vy", "cGVuaXM=", "cGVuaXNmdWNrZXI=", "cGhvbmVzZXg=", "cGh1Y2s=", "cGh1aw==", "cGh1a2Vk", "cGh1a2luZw==", "cGh1a2tlZA==", "cGh1a2tpbmc=", "cGh1a3M=", "cGh1cQ==", "cGlnZnVja2Vy", "cGltcGlz", "cGlzcw==", "cGlzc2Vk", "cGlzc2Vy", "cGlzc2Vycw==", "cGlzc2Vz", "cGlzc2ZsYXBz", "cGlzc2lu", "cGlzc2luZw==", "cGlzc29mZg==", "cG9v", "cG9vcA==", "cG9ybg==", "cG9ybm8=", "cG9ybm9ncmFwaHk=", "cG9ybm9z", "cHJpY2s=", "cHJpY2tz", "cHJvbg==", "cHViZQ==", "cHVzc2U=", "cHVzc2k=", "cHVzc2llcw==", "cHVzc3k=", "cHVzc3lz", "cXVlZWY=", "cmVjdHVt", "cmV0YXJk", "cmltamF3", "cmltbWluZw==", "c19oX2lfdA==", "cy5vLmIu", "c2FkaXN0", "c2NobG9uZw==", "c2NyZXdpbmc=", "c2Nyb2F0", "c2Nyb3Rl", "c2Nyb3R1bQ==", "c2VtZW4=", "c2V4", "c2ghKw==", "c2ghdA==", "c2gxdA==", "c2hhZw==", "c2hhZ2dlcg==", "c2hhZ2dpbg==", "c2hhZ2dpbmc=", "c2hlbWFsZQ==", "c2hpKw==", "c2hpdA==", "c2hpdGRpY2s=", "c2hpdGU=", "c2hpdGVk", "c2hpdGV5", "c2hpdGZ1Y2s=", "c2hpdGZ1bGw=", "c2hpdGhlYWQ=", "c2hpdGluZw==", "c2hpdGluZ3M=", "c2hpdHM=", "c2hpdHRlZA==", "c2hpdHRlcg==", "c2hpdHRlcnM=", "c2hpdHRpbmc=", "c2hpdHRpbmdz", "c2hpdHR5", "c2thbms=", "c2x1dA==", "c2x1dHM=", "c21lZ21h", "c211dA==", "c25hdGNo", "c29uLW9mLWEtYml0Y2g=", "c3BhYw==", "c3B1bms=", "c3B1bmt5", "dDF0dDFlNQ==", "dDF0dGllcw==", "dGVldHM=", "dGVleg==", "dGVzdGljYWw=", "dGVzdGljbGU=", "dGh1bmRlcmN1bnQ=", "dGl0", "dGl0ZnVjaw==", "dGl0cw==", "dGl0dA==", "dGl0dGllNQ==", "dGl0dGllZnVja2Vy", "dGl0dGllcw==", "dGl0dHlmdWNr", "dGl0dHl3YW5r", "dGl0d2Fuaw==", "dG9zc2Vy", "dHVyZA==", "dHc0dA==", "dHdhdA==", "dHdhdGhlYWQ=", "dHdhdHR5", "dHdhdHdhZmZsZQ==", "dHd1bnQ=", "dHd1bnRlcg==", "djE0Z3Jh", "djFncmE=", "dmFnaW5h", "dmlhZ3Jh", "dnVsdmE=", "dzAwc2U=", "d2FuZw==", "d2Fuaw==", "d2Fua2Vy", "d2Fua3k=", "d2hvYXI=", "d2hvcmU=", "d2lsbGllcw==", "d2lsbHk=", "eHJhdGVk", "eHh4"]
    
    static func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        
        return swearWords.reduce(false) { $0 || text.contains($1.base64Decoded()!) }
        
    }
    
}

extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
