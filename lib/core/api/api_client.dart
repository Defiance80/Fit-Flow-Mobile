import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/core/api/interceptors/header_interceptor.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/utils/local_storage.dart';
import 'package:get/get_utils/src/extensions/export.dart';
export 'api_lists.dart';

class Api {
  Api._();

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.addAll(<Interceptor>[HeaderInterceptor()]);

    return dio;
  }

  ///codes
  static const int ok = 200;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int forceUpdate = 410;
  static const int serverError = 500;
  static const int serverNotAvailable = 503;
  static const int validationError = 422;

  static Future<Map<String, dynamic>> post(
    String api, {
    required Map<String, dynamic> data,
  }) async {
    return await rawApiRequest(api, method: 'POST', data: data);
  }

  static Future<Map<String, dynamic>> postMultipart(
    String api, {
    required Map<String, dynamic> data,
    required List<File> files,
    required String fileKey,
  }) async {
    // Prepare map for FormData
    final Map<String, dynamic> formDataMap = {};

    // Add normal fields
    data.forEach((key, value) {
      if (value != null) {
        formDataMap[key] = value;
      }
    });

    // Prepare files list
    final List<MultipartFile> multipartFiles = [];
    for (var i = 0; i < files.length; i++) {
      final File file = files[i];
      if (await file.exists()) {
        final String fileName = file.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
    }

    // Add files to map - if single file, add directly; if multiple, add as list
    if (multipartFiles.length == 1) {
      formDataMap[fileKey] = multipartFiles.first;
    } else {
      formDataMap[fileKey] = multipartFiles;
    }

    // Create FormData using fromMap with ListFormat.multiCompatible
    final formData = FormData.fromMap(formDataMap, ListFormat.multiCompatible);

    return await rawApiRequest(api, method: 'POST', data: formData);
  }

  static Future<Map<String, dynamic>> putMultipart(
    String api, {
    required Map<String, dynamic> data,
    required List<File> files,
    required String fileKey,
  }) async {
    // Prepare map for FormData
    final Map<String, dynamic> formDataMap = {};

    // Add normal fields
    data.forEach((key, value) {
      if (value != null) {
        formDataMap[key] = value;
      }
    });

    // Prepare files list
    final List<MultipartFile> multipartFiles = [];
    for (final file in files) {
      if (await file.exists()) {
        final String fileName = file.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
    }

    if (multipartFiles.isEmpty) {
      // throw ApiException(message: 'No valid files to upload');
    }

    // Add files to map - if single file, add directly; if multiple, add as list
    if (multipartFiles.length == 1) {
      formDataMap[fileKey] = multipartFiles.first;
    } else {
      formDataMap[fileKey] = multipartFiles;
    }

    // Create FormData using fromMap with ListFormat.multiCompatible
    final formData = FormData.fromMap(formDataMap, ListFormat.multiCompatible);

    return await rawApiRequest(api, method: 'PUT', data: formData);
  }

  static Future<Map<String, dynamic>> get(
    String api, {
    Map<String, dynamic>? data,
  }) async {
    return await rawApiRequest(api, method: 'GET', queryParameters: data);
  }

  static Future<Map> put(String api, {Map<String, dynamic>? data}) async {
    return await rawApiRequest(api, method: 'PUT', data: data);
  }

  static Future<Map> patch(String api, {Map<String, dynamic>? data}) async {
    return await rawApiRequest(api, method: 'PATCH', data: data);
  }

  static Future<Map> delete(
    String api, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await rawApiRequest(
      api,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Download a PDF file to local storage
  ///
  /// [api] - The API endpoint
  /// [savePath] - The local path where the PDF should be saved
  /// [data] - POST data to send with the request
  static Future<String> downloadPdf(
    String api, {
    required String savePath,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _dio.download(
        api,
        savePath,
        data: data,
        options: Options(
          method: 'POST',
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return savePath;
    } catch (e) {
      if (e is DioException) {
        final int? responseCode = e.response?.statusCode;

        if (responseCode == unauthorized || responseCode == forbidden) {
          throw UnAuthorizedException();
        } else if (responseCode == serverError) {
          throw ApiException(message: AppLabels.pdfDownloadServerError.tr);
        } else if (responseCode == serverNotAvailable) {
          throw ServerUnavailableException();
        }
      }
      throw AppException(message: AppLabels.pdfDownloadFailed.tr);
    }
  }

  static Future<dynamic> normalDioRequest(
    String api, {
    required String method,
    required Map<String, dynamic> data,
    required Map<String, dynamic> queryParameters,
  }) async {
    final Response response = await _dio.request(
      api,
      queryParameters: queryParameters,
      data: data,
      options: Options(method: method),
    );

    if (response.statusCode == ok) {
      return response.data;
    } else {
      throw ApiException(message: response.data.toString());
    }
  }

  ////This is specific for project structured apis
  static Future<Map<String, dynamic>> rawApiRequest(
    String api, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Use different request methods for FormData vs regular data
      final Response response;

      if (data is FormData) {
        // For FormData, use post/put directly without Options
        if (method == 'POST') {
          response = await _dio.post<dynamic>(
            api,
            data: data,
            options: Options(
              headers: {'Authorization': 'Bearer ${LocalStorage.token}'},
              contentType: 'multipart/form-data',
            ),
          );
        } else if (method == 'PUT') {
          response = await _dio.put(
            api,
            data: data,
            queryParameters: queryParameters,
          );
        } else {
          throw ApiException(
            message: 'Unsupported method for FormData: $method',
          );
        }
      } else {
        // For regular data, use request with Options
        response = await _dio.request(
          api,
          queryParameters: queryParameters,
          data: data,
          options: Options(
            method: method,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      }

      // Handle non-Map responses (like null or string)
      if (response.data == null) {
        throw ApiException(message: AppLabels.nullServerResponse.tr);
      }

      if (response.data is! Map) {
        throw BadResponseFormateException();
      }

      return Map.from(_parseResponse(response));
    } catch (e) {
      if (e is SocketException) {
        throw NoInternetException();
      } else if (e is DioException) {
        final int? responseCode = e.response?.statusCode;
        final dynamic responseData = e.response?.data;

        if (responseCode == null) {
          // No response received - likely network or parsing issue
          throw AppException(
            message: e.message ?? AppLabels.connectionFailed.tr,
          );
        }

        if (responseCode == unauthorized || responseCode == forbidden) {
          throw UnAuthorizedException();
        } else if (responseCode == forceUpdate) {
          throw ForceUpdateRequestException();
        } else if (responseCode == serverError) {
          if (responseData case final Map data) {
            if (data.containsKey('error')) {
              throw ApiException(
                message:
                    responseData['message'] ?? AppLabels.genericServerError.tr,
              );
            }
          }

          throw ApiException(
            message:
                responseData?.toString() ?? AppLabels.genericServerError.tr,
          );
        } else if (responseCode == serverNotAvailable) {
          throw ServerUnavailableException();
        } else if (responseCode == validationError) {
          if (responseData is Map && responseData.containsKey('message')) {
            throw ValidationError(message: responseData['message']);
          } else {
            throw ValidationError();
          }
        } else {
          // Handle null or empty response data
          final errorMessage =
              responseData?.toString() ??
              e.message ??
              AppLabels.unknownError.tr;
          throw AppException(message: errorMessage);
        }
      } else if (e is CustomException) {
        rethrow;
      } else {
        throw AppException(message: e.toString());
      }
    }
  }

  static Map _parseResponse(Response response) {
    if (response.data case final Map data) {
      if (data[ApiParams.error]) {
        throw ApiException(
          message: data[ApiParams.message] ?? '',
          code: response.statusCode?.toString(),
        );
      } else {
        return Map.from(response.data);
      }
    } else {
      throw BadResponseFormateException();
    }
  }
}
