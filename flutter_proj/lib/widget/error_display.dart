import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  
  const ErrorDisplay({Key? key, required this.message}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러오는 중 오류가 발생했습니다',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 재시도 로직 (riverpod의 경우 provider를 refresh)
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}