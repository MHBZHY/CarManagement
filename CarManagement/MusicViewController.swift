//
//  eViewController.swift
//  Music Player
//
//  Created by Amy on 16/6/1.
//  Copyright © 2016年 polat. All rights reserved.
//





import UIKit
import AVFoundation

class MusicViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate {
    
    var audioPlayer = AVAudioPlayer()
    var currentAudio = "";
    var currentAudioPath:NSURL!
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:NSTimer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
    var isTableViewOnscreen = false
    
    @IBOutlet var songNo : UILabel!
    @IBOutlet var lineView : UIView!
    @IBOutlet var songNameLabel : UILabel!
    @IBOutlet var songNameLabelPlaceHolder : UILabel!
    @IBOutlet var progressTimerLabel : UILabel!
    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var listButton : UIButton!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var blurImageView : UIImageView!
    @IBOutlet var enhancer : UIView!
    @IBOutlet var tableViewContainer : UIView!
    
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
        var songNameDict = NSDictionary();
        songNameDict = audioList.objectAtIndex(indexPath.row) as! NSDictionary
        let songName = songNameDict.valueForKey("songName") as! String
        
        var albumNameDict = NSDictionary();
        albumNameDict = audioList.objectAtIndex(indexPath.row) as! NSDictionary
        let albumName = albumNameDict.valueForKey("albumName") as! String
        
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "Didot", size: 25.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = songName
        
        cell.detailTextLabel?.font = UIFont(name: "Didot", size: 16.0)
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = albumName
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(tableView: UITableView,willDisplayCell cell: UITableViewCell,forRowAtIndexPath indexPath: NSIndexPath){
        tableView.backgroundColor = UIColor.clearColor()
        
        let backgroundView = UIView(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor.clearColor()
        cell.backgroundView = backgroundView
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        animateTableViewToOffScreen()
        currentAudioIndex = indexPath.row
        prepareAudio()
        playAudio()
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        effectToggle ? "\(listButton.setImage( showList, forState: UIControlState.Normal))" : "\(listButton.setImage(removeList , forState: UIControlState.Normal))"
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        audioPlayer.playing ? "\(playButton.setImage( pause, forState: UIControlState.Normal))" : "\(playButton.setImage(play , forState: UIControlState.Normal))"
        
    }
    
    
    func captureScreen(){
        self.blurImageView.hidden = true
        self.blurImageView.alpha = 0.0
        
        UIGraphicsBeginImageContext(self.view.bounds.size);
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    
    func applyBlurEffect(image: UIImage){
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        let blurredImage = UIImage(CIImage: resultImage)
        self.blurImageView.image = blurredImage
        self.blurImageView.hidden = false
        self.blurImageView.alpha = 1.0
        
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        if isTableViewOnscreen{
            return true
        }else{
            return false
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enhancer.hidden = true
        //this sets last listened trach number as current
        retrieveSavedTrackNumber()
        prepareAudio()
        updateLabels()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        if flag{
            currentAudioIndex += 1
            if currentAudioIndex>audioList.count-1{
                currentAudioIndex -= 1
                return
            }
            prepareAudio()
            playAudio()
        }
    }
    
    func setCurrentAudioPath(){
        currentAudio = readSongNameFromPlist(currentAudioIndex)
        currentAudioPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(currentAudio, ofType: "mp3")!)
        print("\(currentAudioPath)")
    }
    
    
    func saveCurrentTrackNumber(){
        NSUserDefaults.standardUserDefaults().setObject(currentAudioIndex, forKey:"currentAudioIndex")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func retrieveSavedTrackNumber(){
        
        if let currentAudioIndex_ = NSUserDefaults.standardUserDefaults().objectForKey("currentAudioIndex") as? Int{
            currentAudioIndex = currentAudioIndex_
        }else{
            currentAudioIndex = 0
        }
        
    }
    
    func prepareAudio(){
        setCurrentAudioPath()
              //keep alive audio at background
        do{
           
         try(AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback),
       // AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true),
        //AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents(),
       // audioPlayer = AVAudioPlayer(contentsOfURL: currentAudioPath, error: nil)
        audioPlayer = AVAudioPlayer(contentsOfURL: currentAudioPath))
        audioPlayer.delegate = self
        audioLength = audioPlayer.duration
        playerProgressSlider.maximumValue = CFloat(audioPlayer.duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        audioPlayer.prepareToPlay()
        showTotalSurahLength()
        updateLabels()
        progressTimerLabel.text = "00:00:00"
        }catch
        {
        }
       
        
        
    }
    
    func  playAudio(){
        audioPlayer.play()
        startTimer()
        updateLabels()
        saveCurrentTrackNumber()
    }
    
    func playNextAudio(){
        currentAudioIndex += 1
        if currentAudioIndex>audioList.count-1{
            currentAudioIndex -= 1
            
            return
        }
        if audioPlayer.playing{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func playPreviousAudio(){
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        if audioPlayer.playing{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        audioPlayer.stop();
        
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
        
    }
    
    func startTimer(){
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    
    func update(timer: NSTimer){
        if !audioPlayer.playing{
            return
        }
        
        let hour_   = abs(Int(audioPlayer.currentTime)/3600)
        let minute_ = abs(Int((audioPlayer.currentTime/60) % 60))
        let second_ = abs(Int(audioPlayer.currentTime  % 60))
        
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        
        progressTimerLabel.text  = "\(hour):\(minute):\(second)"
        playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        
    }
    
    
    
    
    func showTotalSurahLength(){
        calculateSurahLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSurahLength(){
        let hour_ = abs(Int(audioLength/3600))
        let minute_ = abs(Int((audioLength/60) % 60))
        let second_ = abs(Int(audioLength % 60))
        
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        totalLengthOfAudio = "\(hour):\(minute):\(second)"
    }
    
    
    
    func readSongNameFromPlist(indexNumber: Int) -> String {
        
        let path = NSBundle.mainBundle().pathForResource("list", ofType: "plist")
        audioList = NSArray(contentsOfFile:path!)
        
        var songNameDict = NSDictionary();
        songNameDict = audioList.objectAtIndex(indexNumber) as! NSDictionary
        let songName = songNameDict.valueForKey("songName") as! String
        return songName
    }
    
    
    
    
    
    func updateLabels(){
        updateSongNameLabel()
        updateBigSongNumber()
        
    }
    
    
    func updateSongNameLabel(){
        let songName = readSongNameFromPlist(currentAudioIndex)
        songNameLabel.text = songName
    }
    
    
    
    func updateBigSongNumber(){
        //   songNo.text = "\(currentAudioIndex+1)"
    }
    
    func animateTableViewToScreen(){
        
        
        
        UIView.animateWithDuration(0.25, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.tableViewContainer.frame = CGRectMake(
                self.tableViewContainer.frame.origin.x,
                17,
                self.tableViewContainer.frame.size.width,
                self.tableViewContainer.frame.size.height)
            
            }, completion: nil)
        
        
    }
    
    func animateTableViewToOffScreen(){
        isTableViewOnscreen = false
        setNeedsStatusBarAppearanceUpdate()
        
        animateBlurImageBack()
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.tableViewContainer.frame = CGRectMake(
                self.tableViewContainer.frame.origin.x,568,
                self.tableViewContainer.frame.size.width,
                self.tableViewContainer.frame.size.height)
            
            }, completion: {
                (value: Bool) in
                self.enhancer.hidden = true
        })
    }
    
    
    func animateBlurImageBack(){
        UIView.animateWithDuration(0.25, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.blurImageView.alpha = 0.0
            }, completion: nil)
    }
    
    
    
    func addDropShadowToTableViewContainer(){
        self.tableViewContainer.layer.shadowColor = UIColor.blackColor().CGColor
        self.tableViewContainer.layer.shadowOffset = CGSizeMake(5.0,5.0)
        self.tableViewContainer.layer.masksToBounds = false
        self.tableViewContainer.layer.shadowRadius = 5.0
        self.tableViewContainer.layer.shadowOpacity = 1.0
    }
    
    
    
    @IBAction func play(sender : AnyObject) {
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if audioPlayer.playing{
            pauseAudioPlayer()
            audioPlayer.playing ? "\(playButton.setImage( pause, forState: UIControlState.Normal))" : "\(playButton.setImage(play , forState: UIControlState.Normal))"
            
        }else{
            playAudio()
            audioPlayer.playing ? "\(playButton.setImage( pause, forState: UIControlState.Normal))" : "\(playButton.setImage(play , forState: UIControlState.Normal))"
        }
    }
    
    
    
    @IBAction func next(sender : AnyObject) {
        playNextAudio()
    }
    
    
    @IBAction func previous(sender : AnyObject) {
        playPreviousAudio()
    }
    
    
    
    
    @IBAction func changeAudioLocationSlider(sender : UISlider) {
        audioPlayer.currentTime = NSTimeInterval(sender.value)
        
    }
    
    
    @IBAction func userTapped(sender : UITapGestureRecognizer) {
        
        play(self)
    }
    
    @IBAction func userSwipeLeft(sender : UISwipeGestureRecognizer) {
        next(self)
    }
    
    @IBAction func userSwipeRight(sender : UISwipeGestureRecognizer) {
        previous(self)
    }
    
    @IBAction func userSwipeUp(sender : UISwipeGestureRecognizer) {
        presentListTableView(self)
    }
    
    
    
    @IBAction func presentListTableView(sender : AnyObject) {
        if effectToggle{
            isTableViewOnscreen = true
            setNeedsStatusBarAppearanceUpdate()
            captureScreen()
            self.applyBlurEffect(self.finalImage)
            self.enhancer.hidden = false
            addDropShadowToTableViewContainer()
            self.animateTableViewToScreen()
            
        }else{
            self.animateTableViewToOffScreen()
            
        }
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        effectToggle ? "\(listButton.setImage( showList, forState: UIControlState.Normal))" : "\(listButton.setImage(removeList , forState: UIControlState.Normal))"
    }
}