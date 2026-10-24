@Test("El identificador de UTType debe coincidir con nuestro esquema")
func testUTTypeIdentifier() {
    #expect(UTType.murdokuObject.identifier == "com.murdoku.object")
}
