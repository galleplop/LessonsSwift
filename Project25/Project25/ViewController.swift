//
//  ViewController.swift
//  Project25
//
//  Created by Guillermo Suarez on 22/4/24.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {

    var images = [UIImage] ()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        let cameraBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let infoBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(infoSearch))
        
        navigationItem.rightBarButtonItems = [cameraBtn, infoBtn]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        
        
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    @objc func importPicture() {
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @objc func showConnectionPrompt() {
        
        let ac = UIAlertController(title: "Connect ro others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(ac, animated: true)
    }
    
    @objc func infoSearch() {
        
        guard let mcSession = mcSession else { return }
        
        let devices:String
        
        if mcSession.connectedPeers.count == 0 {
            
            devices = "No device connected"
        } else {
            devices = mcSession.connectedPeers.map{$0.displayName}.joined(separator: "\n")
        }
        
        let ac = UIAlertController(title: "Devices connected", message: devices, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        self.present(ac, animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project25")
        mcNearbyServiceAdvertiser?.delegate = self
        mcNearbyServiceAdvertiser?.startAdvertisingPeer()
        
    }
    
    func joinSession(action: UIAlertAction) {
        
        guard let mcSession = mcSession else { return }
        
        let mcBrower = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrower.delegate = self
        
        self.present(mcBrower, animated: true)
    }
    
    //MARK: - UIImagePickerControllerDelegate implementation

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        dismiss(animated: true)
        
        guard let mcSession = mcSession else { return }
        
        if mcSession.connectedPeers.count > 0 {
            
            if let imageData = image.pngData() {
                
                do {
                    
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                    
                    let stringData = Data("Send a message".utf8)
                    try mcSession.send(stringData, toPeers: mcSession.connectedPeers, with: .reliable)
                    
                } catch let error {
                    
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    //MARK: - UICollectionViewController implementation
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(10) as? UIImageView {
            
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    //MARK: - MCSessionDelegate implementation
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
            
        case .connected:
            
            print("Connected: \(peerID.displayName)")
        case .connecting:
            
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            
            print("Not Connected: \(peerID.displayName)")
            
            DispatchQueue.main.async {
                [weak self] in
                
                let ac = UIAlertController(title: "\(peerID.displayName) has disconnected", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self?.present(ac, animated: true)
            }
        @unknown default:
            
            print("Unknow state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            [weak self] in
            
            if let image = UIImage(data: data) {
                
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                
                let message = String(decoding: data, as: UTF8.self)
                print("Message recived = \(message)")
            }
        }
    }
    
    //MARK: - MCBrowserViewControllerDelegate implementation
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        self.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        self.dismiss(animated: true)
    }
    
    //MARK: - MCNearbyServiceAdvertiserDelegate implementation
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let ac = UIAlertController(title: "Selfie Share", message: "'\(peerID.displayName)' wants to connect.", preferredStyle: .alert)
        let declineAction = UIAlertAction(title: "Decline", style: .cancel) { [weak self] _ in invitationHandler(false, self?.mcSession) }
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { [weak self] _ in invitationHandler(true, self?.mcSession) }
        
        ac.addAction(declineAction)
        ac.addAction(acceptAction)
        
        present(ac, animated: true)
        
    }
}

