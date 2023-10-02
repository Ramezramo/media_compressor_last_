package com.example.photo_video_compressor_last


import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.*
import java.io.IOException
import java.nio.file.FileAlreadyExistsException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardCopyOption






class MainActivity: FlutterActivity() {
    private val CHANNEL = "NativeChannel"

    @RequiresApi(Build.VERSION_CODES.Q)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if(call.method=="createFolder"){

                //val number = getRandomNumber();
                //result.success(mapOf("RandomNumber" to number));
                val arg1 = call.argument<String>("arg1")
                val arg2 = call.argument<String>("arg2")
                println(arg1)

                println("creating the folder ")

                val foldercreate = createTheFolder();
                result.success(foldercreate)

            }else if (call.method=="giveMEcameraData"){

                var dataReturn = getCameraData()
                result.success(dataReturn)

            } else if (call.method=="deleteSource"){

                val file_path = call.argument<String>("filepath")
                val filePathAsString = file_path?.toString() ?: ""
                deleteSource(filePathAsString)
            }



            else{
                val deleteSource = call.argument<String>("arg1")
                moveFile(call.method,"/storage/emulated/0/MyFolder")
            }
        }
    }


    @RequiresApi(Build.VERSION_CODES.Q)
    private fun createTheFolder(){

        println("inside the function")
        val extStoragePath = Environment.getExternalStorageDirectory ().absolutePath
        // Create a folder name
        val folderName = "MyFolder"
        // Create a File object with the folder path
        val folder = File (extStoragePath, folderName)

        // Check if the folder exists and create it if not
        println("i will check if the folder created or no")
        if (!folder.exists ()) {
            val result = folder.mkdirs ()
            if (result) {
                // The folder was created successfully
                Log.d ("TAG", "Folder created: $folder")
            } else {
                // The folder creation failed
                Log.e ("TAG", "Folder creation failed")
            }
        }else{
            println("the app folder is already existed")
        }
    }


    fun moveFile(from: String, to: String) {
        println("inside the move function")
        println("the from ")
        println(from)
        println("the to ")
        println(to)

        // Get the source file from the internal storage
        val parts = from.split(File.separator)

// Get the last part, which should be the file name
        val fileName = parts.last()
        val directoryPath = parts.dropLast(1).joinToString(File.separator)
        val sourceFile = File(directoryPath, fileName)


        // Get the destination directory from the external storage
        val destinationDir = to

        if (destinationDir != null) {
            // Check if the destination directory exists, and create it if not
//            if (!destinationDir.exists()) {
//                destinationDir.mkdirs()
//            }

            // Create the destination file with the same name as the source file
            val destinationFile = File(destinationDir, sourceFile.name)

            // Move the source file to the destination file using renameTo()
            val result = sourceFile.renameTo(destinationFile)

            // Check if the operation was successful or not
            if (result) {
                // The file was moved successfully
                println("The file was moved successfully to ${destinationFile.path}")
            } else {
                // The file could not be moved
                println("The file could not be moved")
            }
        } else {
            // Handle the case where getExternalFilesDir returned null
            println("External storage directory is null. File move operation failed.")
        }
    }
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun getCameraData(): Map<String, String> {
        println("inside the native fun get camera files")
        val resultMap = mutableMapOf<String, String>()
        try {
            val dcimDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
            if (dcimDirectory != null && dcimDirectory.isDirectory) {
                // Specify the subfolder name where camera files are located
                val subfolderName = "Camera"

                // Create a File object for the subfolder
                val subfolder = File(dcimDirectory, subfolderName)
                println(subfolder)

                if (subfolder.exists() && subfolder.isDirectory) {
                    val subfolderFiles = subfolder.listFiles()
                    println("at 9238745_3458909")
                    println(subfolderFiles)
                    subfolderFiles?.forEach { file ->
                        if (file.isFile) {
                            val path = file.absolutePath
//                            println(path)
                            val lastModified = file.lastModified().toString()
//                            println(lastModified)
                            resultMap[path] = lastModified
                        }
                    }
                }
            }
        } catch (e: Exception) {
            throw e
        }
        return resultMap
    }

    fun deleteSource(file_path :String ) {
        println("in delete source ")
        println(file_path)
    }


}
