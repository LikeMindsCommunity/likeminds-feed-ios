//
//  LMAWSManager.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

import AWSS3
import LikeMindsFeed

public class LMAWSManager {
    private init() { }
    
    public static var shared = LMAWSManager()
    
    typealias progressBlock = (_ progress: Double) -> Void
    typealias completionBlock = (_ response: String?, _ error: Error?) -> Void
    
    public func initialize() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: ServiceAPI.accessKey, secretKey: ServiceAPI.secretAccessKey)
        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    /// This Function uploads Any File type to AWS S3 Bucket
    /// - Parameters:
    ///   - fileUrl: File Path of the file, it is local file url
    ///   - fileName: File Name that we want to keep for our object
    ///   - contenType: Type of Content, can be anything
    ///   - progress: Tells us about the progress rate of uploading
    ///   - completion: What to do after file is done uploading
    func uploadfile(fileUrl: URL, fileName: String, contenType: String, progress: progressBlock?, completion: completionBlock?) {
        // Upload progress block
        do {
            guard fileUrl.startAccessingSecurityScopedResource() else {
                completion?(nil, nil)
                return
            }
            
            let data = try Data(contentsOf: fileUrl)
            fileUrl.stopAccessingSecurityScopedResource()
            
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = {(task, awsProgress) in
                guard let uploadProgress = progress else { return }
                DispatchQueue.main.async {
                    uploadProgress(awsProgress.fractionCompleted)
                    print("progress.fractionCompleted: \(awsProgress.fractionCompleted)")
                    if awsProgress.isFinished{
                        print("Upload Finished...")
                        //do any task here.
                    }
                }
            }
            
            // Completion block
            var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
            completionHandler = { (task, error) -> Void in
                DispatchQueue.main.async(execute: {
                    if error == nil {
                        let url = AWSS3.default().configuration.endpoint.url
                        let publicURL = url?.appendingPathComponent(ServiceAPI.bucketURL).appendingPathComponent(fileName)
                        print("File Uploaded SUCCESSFULLY to:\(String(describing: publicURL))")
                        if let completionBlock = completion {
                            completionBlock(publicURL?.absoluteString, nil)
                        }
                    } else {
                        if let completionBlock = completion {
                            completionBlock(nil, error)
                        }
                        print("File Uploading FAILED with error: \(String(describing: error?.localizedDescription))")
                    }
                })
            }
            
            // Start uploading using AWSS3TransferUtility
            let awsTransferUtility = AWSS3TransferUtility.default()
            awsTransferUtility.uploadData(data, bucket: ServiceAPI.bucketURL, key: fileName, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
                if let error = task.error {
                    print("Error uploading file: \(error.localizedDescription)\n error: \(error)")
                }
                if let _ = task.result {
                    print("Starting upload...")
                }
                return nil
            }
        } catch {
            completion?(nil, nil)
        }
    }
}
