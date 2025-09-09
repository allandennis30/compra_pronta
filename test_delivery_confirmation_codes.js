// Configurar variáveis de ambiente manualmente
process.env.SUPABASE_URL = 'https://feljoannoghnpbqhrsuv.supabase.co';
process.env.SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbGpvYW5ub2dobnBicWhyc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2MjY3ODUsImV4cCI6MjA3MDIwMjc4NX0.uIrk_RMpPaaR2EXSU2YZ-nHvj2Ez5_Wl-3sETF9Tupg';

const supabase = require('./backend/config/supabase');

/**
 * Script para verificar códigos de confirmação de entrega nos pedidos
 */
async function checkDeliveryConfirmationCodes() {
  try {
    console.log('🔍 [TEST] Verificando códigos de confirmação de entrega...');
    
    // Buscar pedidos com códigos de confirmação
    const { data: ordersWithCodes, error: codesError } = await supabase
      .from('orders')
      .select('id, client_name, status, delivery_confirmation_code')
      .not('delivery_confirmation_code', 'is', null)
      .limit(10);
    
    if (codesError) {
      console.error('❌ Erro ao buscar pedidos com códigos:', codesError);
      return;
    }
    
    console.log(`✅ Encontrados ${ordersWithCodes.length} pedidos com códigos de confirmação:`);
    ordersWithCodes.forEach(order => {
      console.log(`   - Pedido ${order.id.substring(0, 8)}... - Status: ${order.status} - Código: ${order.delivery_confirmation_code}`);
    });
    
    // Buscar pedidos sem códigos de confirmação
    const { data: ordersWithoutCodes, error: noCodesError } = await supabase
      .from('orders')
      .select('id, client_name, status, delivery_confirmation_code')
      .is('delivery_confirmation_code', null)
      .limit(5);
    
    if (noCodesError) {
      console.error('❌ Erro ao buscar pedidos sem códigos:', noCodesError);
      return;
    }
    
    console.log(`\n📋 Encontrados ${ordersWithoutCodes.length} pedidos SEM códigos de confirmação:`);
    ordersWithoutCodes.forEach(order => {
      console.log(`   - Pedido ${order.id.substring(0, 8)}... - Status: ${order.status} - Cliente: ${order.client_name}`);
    });
    
    // Se não há pedidos com códigos, vamos criar um código para teste
    if (ordersWithCodes.length === 0 && ordersWithoutCodes.length > 0) {
      const testOrder = ordersWithoutCodes[0];
      const testCode = 'test-confirmation-' + Math.random().toString(36).substring(2, 8);
      
      console.log(`\n🧪 [TEST] Criando código de teste para pedido ${testOrder.id.substring(0, 8)}...`);
      
      const { error: updateError } = await supabase
        .from('orders')
        .update({ 
          delivery_confirmation_code: testCode,
          updated_at: new Date().toISOString()
        })
        .eq('id', testOrder.id);
      
      if (updateError) {
        console.error('❌ Erro ao criar código de teste:', updateError);
      } else {
        console.log(`✅ Código de teste criado: ${testCode}`);
        console.log(`📱 QR Code de teste: delivery_confirm:${testOrder.id}:${testCode}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

// Executar teste
checkDeliveryConfirmationCodes().then(() => {
  console.log('\n🏁 Teste concluído.');
}).catch(error => {
  console.error('❌ Erro fatal:', error);
});