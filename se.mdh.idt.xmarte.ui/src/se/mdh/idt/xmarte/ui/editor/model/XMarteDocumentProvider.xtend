package se.mdh.idt.xmarte.ui.editor.model

import com.google.inject.Inject
import java.io.InputStream
import java.io.StringReader
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.jface.text.IDocument
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.IFileEditorInput
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.xtext.ui.editor.model.XtextDocumentProvider
import org.eclipse.xtext.util.StringInputStream
import se.mdh.idt.xmarte.parser.antlr.XMarteParser
import se.mdh.idt.xmarte.ui.editor.model.transformation.UML2XMarte
import se.mdh.idt.xmarte.ui.editor.model.transformation.XMarte2UML

class XMarteDocumentProvider extends XtextDocumentProvider {

	@Inject XMarteParser parser

	override protected setDocumentContent(IDocument document, InputStream contentStream,
		String encoding) throws CoreException {
		// Instantiate resource set
		val resourceSet = new ResourceSetImpl
		// Retrieve UML model resource
		val umlResource = resourceSet.getResource(URI.createURI("platform:/resource/" + document.get),
			true) as UMLResource
		// Run UML2MarText transformation
		var umlModel = umlResource.contents.get(0) as Model
		var documentContent = UML2XMarte.transform(umlModel).toString
		// Delegate superclass with modified document content
		super.setDocumentContent(document, new StringInputStream(documentContent), encoding)
	}

	override protected setDocumentContent(IDocument document, IEditorInput editorInput,
		String encoding) throws CoreException {
		// Insert editor input resource URI if it is an IFileEditorInput instance
		if (editorInput instanceof IFileEditorInput) {
			document.set((editorInput as IFileEditorInput).file.fullPath.toString)
		}
		// Delegate superclass with modified document
		super.setDocumentContent(document, editorInput, encoding)
	}

	override protected doSaveDocument(IProgressMonitor monitor, Object element, IDocument document,
		boolean overwrite) throws CoreException {
		if (element instanceof IFileEditorInput) {
			// Retrieve FileEditorInput file
			var file = (element as IFileEditorInput).file
			// Instantiate Resource set
			val resourceSet = new ResourceSetImpl
			// Retrieve UML model resource
			val resource = resourceSet.getResource(URI.createURI("platform:/resource/" + file.fullPath.toString), true)
			// Parse document content and transform resulting model to UML
			val parsedModel = parser.parse(new StringReader(document.get)).rootASTElement as Model
			val storedModel = resource.contents.get(0) as Model
			XMarte2UML.transform(storedModel, parsedModel)
			// Save UML resource
			resource.save(null)
		} else {
			// Delegate to superclass if element is not a FileEditorInput instance
			super.doSaveDocument(monitor, element, document, overwrite)
		}
	}

}
