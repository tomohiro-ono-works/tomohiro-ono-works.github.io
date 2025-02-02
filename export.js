import { PrintScaling, PrintPageSize, PrintOrientation  } from "https://public.tableau.com/javascripts/api/tableau.embedding.3.latest.min.js"

document.addEventListener("DOMContentLoaded", () => {
  document.body.addEventListener("click", async (event) => {
    if (event.target.classList.contains("pdf-button")) {
      const index = event.target.getAttribute("data-index");
      await downloadPdf2(index);
    }
  });
});

document.getElementById("master-pdf-button").addEventListener("click", () => {
  document.querySelectorAll(".pdf-button").forEach(button => {
    button.click(); // 各ボタンをクリックした扱いにする
  });
});

// 各ボタンのクリック時の動作
document.querySelectorAll(".pdf-button").forEach(button => {
  button.addEventListener("click", () => {
    console.log(`${button.textContent} がクリックされました！`);
  });
});




/**
 * 指定したダッシュボードのPDFをダウンロードする関数
 */
async function downloadPdf(index) {
  try {
    const tableauViz = document.getElementById(`tableau-viz-${index}`);
    if (!tableauViz) {
      alert("対象のダッシュボードが見つかりません。");
      return;
    }

    await tableauViz.displayDialogAsync("export-pdf");
  } catch (error) {
    console.error("PDFのエクスポートに失敗しました:", error);
  }
}
;
/**
 * 指定したダッシュボードのPDFをダウンロードする関数
 */
async function downloadPdf2(index) {
  try {
    const tableauViz = document.getElementById(`tableau-viz-${index}`);
    if (!tableauViz) {
      alert("対象のダッシュボードが見つかりません。");
      return;
    }

    const publishedSheetsInfo = tableauViz.workbook.publishedSheetsInfo;
    const selectedWorkbookSheetsForExport = Array.from(publishedSheetsInfo, (publishedSheetInfo) => publishedSheetInfo.name);
    const exportPDFOptions = {
      scaling: PrintScaling.Perc60,
      pageSize: PrintPageSize.Letter,
      orientation: PrintOrientation.Portrait,
    };
    tableauViz.exportPDFAsync(selectedWorkbookSheetsForExport, exportPDFOptions).then(() => {
      console.log(`Workbook: ${selectedWorkbookSheetsForExport.toString()}`);
      console.log('Options:', exportPDFOptions);
    });
  } catch (error) {
    console.error("PDFのエクスポートに失敗しました:", error);
  }
}
;
