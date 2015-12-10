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
    
    private var click = AVAudioPlayer()
    private var skip = AVAudioPlayer()
    private var welcome = AVAudioPlayer()
    private var erase = AVAudioPlayer()
    private var fin = AVAudioPlayer()
    private var sent = AVAudioPlayer()
    private var awesome = AVAudioPlayer()
    
    
    func playClickSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            click = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        click.play()
    }
    
    func playSkipSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skip", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            skip = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        skip.play()
    }
    
    func playWelcomeSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("welcome", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            welcome = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        welcome.play()
    }
    
    func playFinSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fin", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            fin = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        fin.volume = 0.025
        fin.play()
    }
    
    func playSentSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sent", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            sent = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        sent.volume = 0.05
        sent.play()
    }
    
    func playAwesomeSound()
    {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("awesome", ofType: "wav")!)
        do {
            //print("Playing: \(sound)")
            awesome = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            print("No sound found by URL: \(sound)")
        }
        awesome.play()
    }
    
    
    
}