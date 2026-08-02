package com.ccdakit.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.ccdakit.compose.CCDADocumentView
import com.ccdakit.engine.CCDAEngine

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface(Modifier.fillMaxSize()) {
                    SampleApp(assetLoader = ::loadAsset)
                }
            }
        }
    }

    private fun loadAsset(fileName: String): ByteArray =
        assets.open(fileName).use { it.readBytes() }
}

@Composable
private fun SampleApp(assetLoader: (String) -> ByteArray) {
    val samples = remember {
        listOf(
            "local-comprehensive-sample.xml",
            "local-media-attachments.xml",
            "hl7-ccd.xml",
            "hl7-discharge-summary.xml",
            "hl7-progress-note.xml",
            "toc-full.xml",
        )
    }
    var selectedSample by remember { mutableStateOf(samples.first()) }
    var documentState by remember { mutableStateOf<Result<com.ccdakit.engine.CCDADocument>?>(null) }
    val engine = remember { CCDAEngine() }

    LaunchedEffect(selectedSample) {
        documentState = runCatching {
            engine.parse(assetLoader(selectedSample))
        }
    }

    Row(Modifier.fillMaxSize()) {
        LazyColumn(Modifier.weight(0.35f)) {
            items(samples) { sample ->
                Text(
                    text = sample.removeSuffix(".xml"),
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { selectedSample = sample }
                        .padding(12.dp),
                    style = if (sample == selectedSample) {
                        MaterialTheme.typography.titleSmall
                    } else {
                        MaterialTheme.typography.bodyMedium
                    },
                )
            }
        }

        Column(Modifier.weight(0.65f)) {
            Text(
                text = selectedSample,
                modifier = Modifier.padding(12.dp),
                style = MaterialTheme.typography.titleMedium,
            )

            when (val result = documentState) {
                null -> Text("Loading", Modifier.padding(12.dp))
                else -> result.fold(
                    onSuccess = {
                        CCDADocumentView(
                            document = it,
                            modifier = Modifier.fillMaxSize(),
                        )
                    },
                    onFailure = { Text(it.message ?: "Unable to parse sample", Modifier.padding(12.dp)) },
                )
            }
        }
    }
}
