/**
 * 스프레드시트의 데이터를 JSON 형식으로 변환하는 함수
 * 각 행의 첫 번째 열(id)을 키로 사용하여 JSON 객체를 생성
 */
function spreadsheetToJson() {
  // 현재 활성화된 스프레드시트와 시트 가져오기
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getActiveSheet();
  
  // 데이터 범위 가져오기
  const dataRange = sheet.getDataRange();
  const values = dataRange.getValues();
  
  // 헤더 행 (첫 번째 행)
  const headers = values[0];
  
  // 결과 JSON 객체
  const jsonData = {};
  
  // 데이터 행 처리 (두 번째 행부터)
  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    const rowData = {};
    
    // id 값을 키로 사용
    const idValue = row[0];
    
    // 각 열의 데이터를 처리
    for (let j = 0; j < headers.length; j++) {
      const header = headers[j];
      
      // 헤더가 "_"로 시작하면 건너뛰기
      if (header.startsWith('_')) {
        continue;
      }
      
      let value = row[j];
      
      // 숫자인 경우 숫자 타입으로 변환
      if (!isNaN(value) && value !== "" && typeof value !== 'boolean') {
        value = Number(value);
      }
      
      // 객체에 키-값 추가
      rowData[header] = value;
    }
    
    // 결과 JSON에 추가
    jsonData[idValue] = rowData;
  }
  
  // JSON 문자열로 변환
  const jsonString = JSON.stringify(jsonData);
  
  // 로그에 JSON 출력 (테스트용)
  Logger.log(jsonString);
  
  return jsonString;
}

/**
 * UI에 메뉴 추가
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('✅👉JSON 변환👈✅')
    .addItem('스프레드시트를 JSON으로 변환(언더바 무시)', 'showJson')
    .addToUi();
}

/**
 * JSON 결과를 보여주는 사이드바 표시
 */
function showJson() {
  const jsonData = spreadsheetToJson();
  
  // HTML 사이드바 생성 (다운로드 버튼 추가)
  const htmlOutput = HtmlService
    .createHtmlOutput(`
      <div style="padding: 20px;">
        <button onclick="downloadJson()" style="margin-bottom: 20px; padding: 10px; background-color: #4285f4; color: white; border: none; border-radius: 4px; cursor: pointer;">
          JSON 파일 다운로드
        </button>
        <pre style="white-space: pre-wrap;">${jsonData}</pre>
      </div>
      <script>
        function downloadJson() {
          const jsonData = ${jsonData};
          const blob = new Blob([JSON.stringify(jsonData, null, 2)], {type: 'application/json'});
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = 'historical_events.json';
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }
      </script>
    `)
    .setTitle('JSON 변환 결과');
  
  SpreadsheetApp.getUi().showSidebar(htmlOutput);
}

function main() {
    spreadsheetToJson();
}