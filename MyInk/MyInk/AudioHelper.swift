//
//  AudioHelper.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-09.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import AVFoundation



class AudioHelper {
    
    fileprivate var click = AVAudioPlayer()
    fileprivate var skip = AVAudioPlayer()
    fileprivate var welcome = AVAudioPlayer()
    fileprivate var erase = AVAudioPlayer()
    fileprivate var fin = AVAudioPlayer()
    fileprivate var sent = AVAudioPlayer()
    fileprivate var awesome = AVAudioPlayer()
    fileprivate var yeah = AVAudioPlayer()
    
    func playClickSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "click", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            click = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        click.play()
    }
    
    func playSkipSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "skip", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            skip = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        skip.play()
    }
    
    func playWelcomeSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "welcome", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            welcome = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        welcome.play()
    }
    
    func playFinSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "fin", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            fin = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        fin.volume = 0.025
        fin.play()
    }
    
    func playSentSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "sent", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            sent = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        sent.volume = 0.05
        sent.play()
    }
    
    func playAwesomeSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "awesome", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            awesome = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        awesome.play()
    }
   
    func playYeahSound()
    {
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "yeah", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            yeah = try AVAudioPlayer(contentsOf: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        yeah.volume = 0.05
        yeah.play()
    }
    
    
    
}
