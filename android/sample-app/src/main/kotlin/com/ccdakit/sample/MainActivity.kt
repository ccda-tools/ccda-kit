package com.ccdakit.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
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
import com.ccdakit.engine.CCDADocument
import com.ccdakit.engine.CCDAEngine
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

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
    var selectedSample by remember { mutableStateOf<String?>(null) }

    when (val sample = selectedSample) {
        null -> SampleListScreen(
            samples = samples,
            onSelectSample = { selectedSample = it },
        )
        else -> SampleDocumentScreen(
            sampleName = sample,
            assetLoader = assetLoader,
            onBack = { selectedSample = null },
        )
    }
}

@Composable
private fun SampleListScreen(samples: List<String>, onSelectSample: (String) -> Unit) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        item {
            Column(Modifier.fillMaxWidth().padding(16.dp)) {
                Text(
                    text = "C-CDA Samples",
                    style = MaterialTheme.typography.headlineSmall,
                )
                Text(
                    text = "Select a document",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        items(samples) { sample ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSelectSample(sample) }
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                Text(
                    text = sample.removeSuffix(".xml"),
                    style = MaterialTheme.typography.titleSmall,
                )
                Text(
                    text = "C-CDA XML",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            HorizontalDivider()
        }
    }
}

@Composable
private fun SampleDocumentScreen(
    sampleName: String,
    assetLoader: (String) -> ByteArray,
    onBack: () -> Unit,
) {
    BackHandler(onBack = onBack)

    var documentState by remember(sampleName) { mutableStateOf<Result<CCDADocument>?>(null) }
    val engine = remember { CCDAEngine() }

    LaunchedEffect(sampleName) {
        documentState = null
        documentState = withContext(Dispatchers.IO) {
            runCatching {
                engine.parse(assetLoader(sampleName))
            }
        }
    }

    Column(Modifier.fillMaxSize()) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                    contentDescription = "Back",
                )
            }
            Text(
                text = sampleName.removeSuffix(".xml"),
                modifier = Modifier.padding(top = 12.dp),
                style = MaterialTheme.typography.titleMedium,
            )
        }
        HorizontalDivider()

        when (val result = documentState) {
            null -> Text("Loading", Modifier.padding(16.dp))
            else -> result.fold(
                onSuccess = { document ->
                    CCDADocumentView(
                        document = document,
                        modifier = Modifier.fillMaxSize(),
                    )
                },
                onFailure = { Text(it.message ?: "Unable to parse sample", Modifier.padding(16.dp)) },
            )
        }
    }
}
