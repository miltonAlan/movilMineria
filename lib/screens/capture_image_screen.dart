import 'package:ejemplo/screens/drawer_modular.dart';
import 'package:ejemplo/screens/ejemplo_uso_firebase.dart';
import 'package:ejemplo/screens/resultados_admin.dart';
import 'package:ejemplo/screens/text_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Asegúrate de agregar esta línea

import 'package:ejemplo/providers/captured_images_model.dart';
import 'package:ejemplo/screens/auth_screen.dart';
import 'package:ejemplo/screens/measurement_screen.dart';
import 'package:image/image.dart' as img;

class CaptureImageScreen extends StatefulWidget {
  @override
  _CaptureImageScreenState createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  String _currentPage = '/capture';
  bool _isProcessing = false;
  List<String> processedImagePaths = [];

  @override
  Widget build(BuildContext context) {
    final capturedImagesModel = Provider.of<CapturedImagesModel>(context);
    bool hasImages = capturedImagesModel.capturedImages.isNotEmpty;
    final String rol =
        Provider.of<TestResultProvider>(context).rol ?? "Rol no definido";
    final String nombreTrabajador =
        Provider.of<TestResultProvider>(context).nombreTrabajador ??
            "Nombre no definido";

    return Scaffold(
      appBar: AppBar(
        title: Text('Carga de Fotografias'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: _openCamera,
              ),
              IconButton(
                icon: Icon(Icons.collections),
                onPressed: _pickMultipleImagesFromGallery,
              ),
            ],
          ),
        ],
      ),
      drawer:
          AppDrawerAndNavigation.buildDrawer(context, rol, nombreTrabajador),
      body: Center(
        child: capturedImagesModel.capturedImages.isEmpty
            ? Text('No se ha capturado ninguna imagen')
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: capturedImagesModel.capturedImages.length,
                itemBuilder: (context, index) {
                  String imagePath = capturedImagesModel.capturedImages[index];
                  String fileName = _getFileName(imagePath);

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Center(
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            fileName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: Stack(
        children: [
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed:
                      hasImages && !_isProcessing ? _processImages : null,
                  label: _isProcessing
                      ? SizedBox(
                          width: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Procesando...'),
                              SizedBox(width: 10),
                              CircularProgressIndicator(),
                            ],
                          ),
                        )
                      : Text('Procesar Imágenes'),
                  icon: Icon(Icons.settings), // Icono de engranaje
                ),
                FloatingActionButton.extended(
                  onPressed: hasImages && !_isProcessing ? _clearImages : null,
                  label: Text('Borrar Todas'),
                  icon: Icon(Icons.close), // Agregar el icono de una X
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File compressedImage = await compressImage(File(pickedFile.path));
      Provider.of<CapturedImagesModel>(context, listen: false)
          .addCapturedImage(compressedImage.path);
    }
  }

  Future<File> compressImage(File file) async {
    // Lee la imagen original
    final imageBytes = await file.readAsBytes();

    // Decodifica la imagen
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      // Manejar la situación en la que no se puede decodificar la imagen
      throw Exception('No se pudo decodificar la imagen.');
    }

    // Redimensiona la imagen si es necesario
    final maxWidth = 800; // Cambia este valor según tus necesidades
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    // Comprime la imagen reduciendo su calidad
    final compressedFile =
        File('${file.parent.path}/compressed_${file.uri.pathSegments.last}');
    await compressedFile.writeAsBytes(img.encodeJpg(image,
        quality: 70)); // Ajusta la calidad según tus necesidades

    return compressedFile;
  }

  Future<void> _pickMultipleImagesFromGallery() async {
    List<Asset> pickedImages = [];
    try {
      pickedImages = await MultiImagePicker.pickImages(
        maxImages: 99,
        enableCamera: true,
      );
    } catch (e) {
      print("Error al seleccionar imágenes: $e");
    }

    if (pickedImages.isNotEmpty) {
      List<String> imagePaths = [];
      for (var asset in pickedImages) {
        imagePaths.add(await _getImagePath(asset));
      }
      Provider.of<CapturedImagesModel>(context, listen: false)
          .addCapturedImages(imagePaths);
    }
  }

  Future<String> _getImagePath(Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String imagePath = "${tempDir.path}/${asset.name}";
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageData);
    return imagePath;
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  void _removeImage(int index) {
    Provider.of<CapturedImagesModel>(context, listen: false)
        .removeCapturedImage(index);
  }

  Future<void> _processImages() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final capturedImagesModel =
          Provider.of<CapturedImagesModel>(context, listen: false);
      processedImagePaths = [];

      // print("XXXXXX si vacia la lista");
      capturedImagesModel
          .clearCapturedImagesProcessed(); // Vaciar la nueva lista de imágenes procesadas
      for (String imagePath in capturedImagesModel.capturedImages) {
        File imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          String responseString = await _processImage(imageFile);
          // print(responseString);
          // await _processImage(imageFile);
          // String processedImagePath = await _processImage(imageFile);
          capturedImagesModel.addCapturedImageProcessed(
              imagePath, responseString); // Agregar a la nueva lista
        }
      }

      setState(() {
        _isProcessing = false;
      });

      _showProcessedMessage(context); // Mostrar el mensaje aquí
    } catch (error) {
      print("Error al procesar imágenes: $error");
    }
  }

  Future<String> _processImage(File imageFile) async {
    final apiRuta = '/propio';
    final testResultProvider =
        Provider.of<TestResultProvider>(context, listen: false);
    String url = testResultProvider.text; // Acceder a _testResult
    String rol = testResultProvider.rol; // Acceder a role
    final apiUrl = url + apiRuta;
    // print('URLXXXXXXXXXXXXx' + url);
    // print('apirutaXXXXXXXXXXXXx' + apiRuta);
    // print("apiUrlXXXXXXXXx: " + apiUrl);
    // print("rol: " + rol);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('img', imageFile.path));

      request.followRedirects = false;

      var response = await request.send();

      var responseString = await response.stream.bytesToString();
      print("API Response Status Code: ${response.statusCode}");
      // print("API Response String: $responseString");

      return responseString; // Devuelve la cadena de respuesta
    } catch (e) {
      print("Error al procesar imagen: $e");
      throw Exception('Error en la petición de la API');
    }
  }

  void _onOptionSelected(BuildContext context, String route, Widget screen) {
    if (_currentPage != route) {
      setState(() {
        _currentPage = route;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _clearImages() {
    Provider.of<CapturedImagesModel>(context, listen: false)
        .clearCapturedImages();
  }

  void _showProcessedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Imágenes Procesadas'),
          content: Text('Dirígete hacia la pantalla de Resultados'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
